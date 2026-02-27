/// 
/// Интерфейс, через который операция может вернуть активность пользователя:
/// «Меня нажали / изменили".
/// 
/// Это сохраняет твою Operation независимой и тестируемой от глобального состояния приложения.
abstract class OperationActions {
  void onChanged(int operationId, String eventId, dynamic payload);
}