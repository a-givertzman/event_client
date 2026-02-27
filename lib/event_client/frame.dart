import 'dart:typed_data';

import 'package:event_client/event_client/content.dart';
import 'package:event_client/event_client/cot.dart';
import 'package:event_client/operation/operation.dart';
import 'package:event_client/operation/operation_id.dart';

///
/// Контейнер для доставки сообщений из парсера `Message` в диспетчер EventClient
class Frame {
  /// Frame id, used internal only to identify incoming request message
  final int id;   // u32,
  /// Name of the [Operation]
  final OperationId operationId;
  /// Cause of the transmission
  final Cot cot;
  /// Kind of the content in the `Data` field of  the socket `Message`
  final Content content;
  /// Payload data of the [Frame], received or to be sent to the socket directly 
  // final Bytes bytes;
  final Uint8List bytes;
  ///
  /// Returns [Frame] new instance
  Frame(this.id, this.operationId, this.cot, this.content, this.bytes);
  // ///
  // ///
  // final Map<Type, dynamic Function(Uint8List)> _registry = {
  //   Temperature: (bytes) => Temperature.fromBytes(bytes),
  //   Torque: (bytes) => Torque.fromBytes(bytes),
  // };
  ///
  /// Returns the [Operation] corresponding to OperationId
  Operation operation() {
    switch (content) {
      case Content.bytes:
        return Operation.fromRawBytes(operationId, bytes);
      case Content.empty:
        return Operation.empty(operationId, bytes);
      case Content.json:
        return Operation.fromJsonBytes(operationId, bytes);
    }
  }
}
