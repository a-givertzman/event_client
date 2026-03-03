import 'dart:async';
import 'package:event_client/event_client/message.dart';
import 'package:event_client/operation/operation.dart';
import 'package:event_client/operation/operation_id.dart';
import 'package:hmi_core/hmi_core_log.dart';
///
/// Provides subscription for the events from the network.
class EventClient {
  final _log = const Log("EventClient");
  final Message _message;
  final Map<OperationId, Operation> _cache;
  final Map<OperationId, StreamController<Operation>> _subscriptions = {};
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
  /// Returns a stream of [Operation] for a given subscription [path].
  /// - Creates a new stream if one doesn't exist.
  // Stream<T> stream<T extends Operation>(String path) {
  //   final chached = _cache[path];
  //   final controller = _subscriptions.putIfAbsent(path, () => StreamController<T>.broadcast());
  //   if (controller is StreamController<T>) {
  //     if (chached != null) {
  //       controller.add(chached as T);
  //     }
  //     return controller.stream;
  //   } else {
  //     throw StateError(
  //       'EventClient.stream | `$path` isn`t coresponds to the requested type `$T`'
  //     );
  //   }
  // }
  ///
  /// Returns a stream of [Operation] for a given subscription [path].
  /// - Creates a new stream if one doesn't exist.
  Stream<Operation> stream(String path) {
    final cached = _cache[path];

    final sub = _subscriptions.putIfAbsent(path, () {
      return _TypedSubscription(
        T,
        StreamController<Operation>.broadcast(),
      );
    });

    if (sub.type != T) {
      throw StateError(
        'EventClient.stream | `$path` already registered with type `${sub.type}`, requested `$T`'
      );
    }

    if (cached != null) {
      sub.controller.add(cached);
    }

    return sub.controller.stream.cast<T>();
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
  /// Sends [operation] to the server.
  void send(Operation operation) {
    _message.add(operation);
  }
  ///
  /// Requests [operation] from the server.
  Future<T> request<T extends Operation>(Operation operation) {
    return _message.request(operation);
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
