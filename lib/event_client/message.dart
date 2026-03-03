import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:event_client/event_client/connect.dart';
import 'package:event_client/domain/types/bytes.dart';
import 'package:event_client/event_client/frame.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:hmi_core/hmi_core_option.dart';
import 'package:hmi_core/hmi_core_result.dart';
///
/// Converts `Stream<List<int>>` into `Stream<Point>`.
/// Sends [Frame] converting it into `List<int>`.
class Message {
  final _log = const Log("Message");
  // - `_connect` - Socket connection
  final Connect _connect;
  // - '_controller` - StreamController output stream of bytes
  final StreamController<Frame> _controller = StreamController();
  bool _isStarted = false;
  int _messageId = 0;
  // - `_subscriptions` - subscriptions on certain device
  late StreamSubscription? _subscription;
  final MessageBuild _messageBuild = MessageBuild(
    syn: FieldSyn.def(),
    id: FieldId.def(),
    kind: FieldKind.bytes,
    size: FieldSize.def(),
    data: FieldData([]),
  );
  ///
  /// Creates a new insance of [Message] with established [connect].
  Message({required Connect connect}) : _connect = connect;
  ///
  /// Stream of points coming from the connection line.
  /// Returns a stream of [Frame].
  Stream<Frame> get stream {
    if (!_isStarted) {
      _isStarted = true;
      final message = ParseData(
        field: ParseSize(
          size: FieldSize.def(),
          field: ParseKind(
            field: ParseId(
              id: FieldId.def(),
              field: ParseSyn.def(),
            ),
          ),
        ),
      );
      _subscription = _connect.stream.listen((Bytes bytes) {
        // _log.debug('.listen.onData | Frame: $event');
        Bytes? input = bytes;
        bool isSome = true;
        while (isSome) {
          switch (message.parse(input)) {
            case Some<(FieldId, FieldKind, FieldSize, Bytes)>(
                value: (final _, final _, final _, final bytes)
              ):
              // _log.debug('.listen.onData | id: $id,  kind: $kind,  size: $size, bytes: ${bytes.length > 16 ? bytes.sublist(0, 16) : bytes}');
              switch (_parse(bytes)) {
                case Ok<Frame, Failure>(value: final point):
                  _controller.add(point);
                case Err<Frame, Failure>(:final error):
                  _log.warn('.stream.listen | Error: $error');
              }
              input = null;
            case None():
              isSome = false;
            // _log.debug('.listen.onData | None');
          }
        }
      }, onDone: () async {
        _log.debug('.stream.listen.onDone | Done');
        await _subscription?.cancel();
        await _connect.close();
      }, onError: (err) {
        _log.warn('.stream.listen.onError | Error: $err');
      });
    }
    return _controller.stream;
  }
  ///
  /// Sends [frame] to the connection line.
  void add(Frame frame) {
    Uint8List bytes = _toBytes(frame);
    // _log.debug('.add | id: $id,  bytes: ${bytes.length > 16 ? bytes.sublist(0, 16) : bytes}');
    _messageId++;
    _connect.add(_messageBuild.build(bytes, id: _messageId));
  }
  ///
  /// Converts [point] to JSON, then to bytes.
  Uint8List _toBytes(Frame frame) {
    final map = {
      'name': frame.id,
      'type': frame.operationId.toStr(),
      'value': frame.data,
      'status': frame.status.toInt(),
      'timestamp': frame.timestamp,
    };
    final jsonVal = json.encode(map);
    return utf8.encode(jsonVal);
  }
  //
  //
  Result<Frame, Failure> _parse(List<int> bytes) {
    try {
      String message = String.fromCharCodes(bytes).trim();
      final jsonVal = json.decode(message);
      final name = jsonVal['name'];
      final type = OperationId.fromStr(jsonVal['type']);
      final value = switch (type) {
        OperationId.bool => jsonVal['value'],
        OperationId.int => jsonVal['value'],
        OperationId.real => jsonVal['value'],
        OperationId.double => jsonVal['value'],
        OperationId.string => jsonVal['value'],
      };
      var status = Status.fromInt(jsonVal['status']);
      var timestamp = jsonVal['timestamp'];
      return Ok(Frame(
        id: name,
        operationId: type,
        data: value,
        status: status,
        timestamp: timestamp,
      ));
    } catch (err) {
      return Err(Failure('Message.parse | Parsing error: $err'));
    }
  }
  ///
  /// Returns a [Future] that completes once all buffered data is accepted by the underlying [StreamConsumer].
  ///
  /// This method must not be called while an [addStream] is incomplete.
  ///
  /// NOTE: This is not necessarily the same as the data being flushed by the operating system.
  Future flush() {
    return _connect.flush();
  }
  ///
  /// Reases all resources.
  Future<void> close() async {
    await _subscription?.cancel();
    await _connect.close();
    await _controller.close();
  }
}
