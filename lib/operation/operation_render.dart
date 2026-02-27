import 'package:event_client/operation/operation_actions.dart';
import 'package:flutter/material.dart';

///
/// Интерфейс для дефолной отрисовки [Operation]
abstract class OperationRender {
  /// 
  /// Возвращает простейший виджет по умолчанию для данного объекта
  /// 
  /// - [actions] - Интерфейс, через который можно вернуть активность пользователя на виджете
  Widget render(BuildContext context, {OperationActions actions});
}
