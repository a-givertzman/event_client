import 'package:event_client/event_client/event_client.dart';
import 'package:event_client/operation/operation.dart';

///
/// Мутация состояния (Intents)
/// 
/// Изменение состояния — только через сервер round-trip.
/// 
/// - **Запрещено**: Менять `_map` внутри Operation's
/// - **Запрещено** Вызывать Intent внутри render().
/// - **Flow**: UI -> Intent(Operation) -> Backend -> EventClient -> New Operation -> UI.
/// - **Типизация**: Известно какой тип мы ожидаем при Operation.intent(client).request()
///   * Request декларирует ожидаемый тип ответа.
///   * Финальная типизация производится Operation.factory на основании OperationId.
class OperationIntent<T extends Operation> {
  final EventClient client;
  final T operation;

  OperationIntent(this.client, this.operation);

  void send() {
    client.send(operation);
  }

  Future<T> request() {
    return client.request(operation);
  }
}
///
/// Extension to create [OperationIntent] for [Operation]
extension OperationIntentExt<T extends Operation> on T {
  OperationIntent<T> intent(EventClient client) {
    return OperationIntent<T>(client, this);
  }
}
