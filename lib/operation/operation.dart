import 'dart:convert';

import 'package:event_client/operation/operation_actions.dart';
import 'package:event_client/operation/operation_id.dart';
import 'package:event_client/operation/operation_render.dart';
import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';

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
  factory Operation.empty(OperationId operationId, List<int> bytes) {
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
        OperationId.temperature => Temperature.fromJsonMap(jsonMap),
        _ => OperationFail("Operation.fromJsonBytes | Operation '$operationId' can't be parsed from JSON bytes, RAW bytes expected"),
      };
    } catch (err) {
      final err_ = "Operation.fromBytes | Can't parse '$operationId', error: $err";
      _log.warn(err_);
      return OperationFail(err_);
    }
  }
}
///
/// [Operation]'s empty variant
final class OperationEmpty extends Operation implements OperationRender {
  final OperationId _operationId;
  const OperationEmpty(OperationId operationId):
    _operationId = operationId,
    super._();
  //
  @override
  String toString() {
    return "OperationEmpty | Empty object for '$_operationId'";
  }
  //
  @override
  Widget render(BuildContext context, {OperationActions actions}) {
    return Text("OperationEmpty | Empty object for '$_operationId'");
  }
}
///
/// [Operation]'s parse errors container
final class OperationFail extends Operation implements OperationRender {
  final String _err;
  const OperationFail(String err):
    _err = err,
    super._();
  //
  @override
  String toString() {
    return _err;
  }
  //
  @override
  Widget render(BuildContext context, {OperationActions actions}) {
    return Text(_err);
  }
}
///
/// System diagnosis structure
final class SysDiag extends Operation {
  SysDiag.fromJsonMap(Map<String, dynamic> map): super._();
}
///
/// Temperature
final class Temperature extends Operation implements OperationRender {
  final Map<String, dynamic> _map;
  // const Temperature(double celsius): _celsius = celsius;
  Temperature.fromJsonMap(Map<String, dynamic> map): 
    _map = map,
    super._();
  //
  @override
  Widget render(BuildContext context, {OperationActions actions}) {
    return Text(_map['value'] ?? 'Temperature.render | Missed field "value"');
  }
}
///
/// Torque
final class Torque extends Operation implements OperationRender {
  final Map<String, dynamic> _map;
  Torque.fromJsonMap(Map<String, dynamic> map):
    _map = map,
    super._();
  //
  @override
  Widget render(BuildContext context, {OperationActions actions}) {
    return Text(_map['value'] ?? 'Temperature.render | Missed field "value"');
  }
}
///
/// PressureState
final class PressureState extends Operation {
  PressureState.fromJsonMap(Map<String, dynamic> map): super._();
}
///
/// MotorSpeed
final class MotorSpeed extends Operation {
  MotorSpeed.fromJsonMap(Map<String, dynamic> map): super._();
}
///
/// MotorCurrent
final class MotorCurrent extends Operation {
  MotorCurrent.fromJsonMap(Map<String, dynamic> map): super._();
}
///
/// FilePdf
final class FilePdf extends Operation {
  FilePdf.fromBytes(List<int> bytes): super._();
}
///
/// FileHtml
final class FileHtml extends Operation {
  FileHtml.fromBytes(List<int> bytes): super._();
}
