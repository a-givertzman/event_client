library operation;

import 'dart:convert';

import 'package:event_client/example_widgets/edit_widget.dart';
import 'package:event_client/operation/actions/edit_actions.dart';
import 'package:event_client/operation/operation_actions.dart';
import 'package:event_client/operation/operation_id.dart';
import 'package:event_client/operation/operation_render.dart';
import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';

part 'operations/operations_app.dart';
part 'operations/operations_basic.dart';

/// 
/// Центральная точка входа в преобразование байтов во `frame` в доменный типы.
/// 
/// - Содержит фабрику-диспетчер.
/// - Конкретный тип выбирается на основании [OperationId] 
/// - Возвращает конкретный если байты успешно преобразованы в запрошенный [Content] 
/// - Возвращает [OperationFail] если в процессе возникла ошибка
sealed class Operation {
  static const _log = Log("Operation");
  ///
  /// Invisible in public, just for the ierarchy
  const Operation._();
  ///
  /// Returns [Operation] empty object
  factory Operation.empty(OperationId operationId, List<int> payload) {
    return OperationEmpty(operationId);
  }
  ///
  /// Returns [Operation] built from the raw bytes, NOT JSON
  factory Operation.fromRawBytes(OperationId operationId, List<int> bytes) {
      return switch (operationId) {
        // OperationId.deviceInfo => OperationFail("Operation.fromRawBytes | Operation '$operationId' can't be parsed from raw bytes, JSON expected"),
        // OperationId.deviceDoc => OperationFail("Operation.fromRawBytes | Operation '$operationId' can't be parsed from raw bytes, JSON expected"),
        // OperationId.temperature => OperationFail("Operation.fromRawBytes | Operation '$operationId' can't be parsed from raw bytes, JSON expected"),
        OperationId.filePdf => FilePdf.fromBytes(bytes),
        OperationId.fileHtml => FileHtml.fromBytes(bytes),
        _ => OperationFail("Operation.fromRawBytes | Operation '$operationId' can't be parsed from raw bytes, JSON expected"),
      };
  }
  ///
  /// Returns [Operation] built from the JSON bytes
  factory Operation.fromJsonBytes(OperationId operationId, List<int> bytes) {
    try {
      final String jsonString = utf8.decode(bytes);
      final dynamic jsonMap = json.decode(jsonString);
      if (jsonMap is! Map<String, dynamic>) {
        throw const FormatException('JSON payload is not a Map');
      }
      // Выбираем конкретный подкласс на основе `OperationId`
      return switch (operationId) {
        OperationId.deviceInfo => throw UnimplementedError('Not implemented'),
        OperationId.deviceDoc => throw UnimplementedError('Not implemented'),
        OperationId.temperature => MotorTemperature.fromJsonMap(jsonMap),
        _ => OperationFail("Operation.fromJsonBytes | Operation '$operationId' can't be parsed from JSON bytes, RAW bytes expected"),
      };
    } catch (err) {
      final err_ = "Operation.fromBytes | Can't parse '$operationId', error: $err";
      _log.warn(err_);
      return OperationFail(err_);
    }
  }
  ///
  /// Returns coresponding [OperationId]
  OperationId id();
}
