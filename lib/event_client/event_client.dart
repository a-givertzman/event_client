import 'dart:async';
import 'package:event_client/event_client/message.dart';
import 'package:event_client/operation/operation.dart';
import 'package:hmi_core/hmi_core_log.dart';
///
/// Provides subscription for the events from the network.
class EventClient {
  final _log = const Log("EventClient");
  final Message _message;
  final Map<String, Operation> _cache;
  final Map<String, StreamController<Operation>> _subscriptions = {};
  ///
  /// Creates a new instance of [EventClient] with incoming [message]
  EventClient({
    required Message message,
  }):
    _message = message,
    _cache = {} {
    _listenConnection();
  }
  ///
  /// Returns a stream of [Operation] for a given subscription [name]. Creates a new stream if one doesn't exist.
  Stream<Operation> stream(String name) {
    final chached = _cache[name];
    final controller = _subscriptions.putIfAbsent(name, () => StreamController<Operation>.broadcast());
    if (chached != null) {
      controller.add(chached);
    }
    return controller.stream;
  }
  ///
  /// Listening to the events from the connection.
  void _listenConnection() {
    _message.stream.listen(
      (event) {
        final name = event.id;
        final controller = _subscriptions[name];
        if (controller != null) {
          controller.add(event);
        }
      },
      onDone: () async {
        _log.warn('._listenConnection.listen | Done');
        _message.close();
        await Future.delayed(const Duration(milliseconds: 100));
        _listenConnection();
      },
      onError: (err) {
        _log.warn('._listenConnection.listen | Connection error: $err');
      },
    );
  }
  ///
  /// Releases all resources.
  void close() {
    _message.close();
    for (var controller in _subscriptions.values) {
      controller.close();
    }
    _subscriptions.clear();
  }
}
