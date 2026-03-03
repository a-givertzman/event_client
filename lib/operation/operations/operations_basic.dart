part of '../operation.dart';

///
/// [Operation]'s empty variant
final class OperationEmpty extends Operation implements OperationRender {
  final OperationId _operationId;
  const OperationEmpty(OperationId operationId):
    _operationId = operationId,
    super._();
  //
  @override
  OperationId id() => OperationId.operationEmpty;
  //
  @override
  String toString() {
    return "OperationEmpty | Empty object for '$_operationId'";
  }
  //
  @override
  Widget render(BuildContext context, {OperationActions? actions}) {
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
  OperationId id() => OperationId.operationFail;
  //
  @override
  String toString() {
    return _err;
  }
  //
  @override
  Widget render(BuildContext context, {OperationActions? actions}) {
    return Text(_err);
  }
}
