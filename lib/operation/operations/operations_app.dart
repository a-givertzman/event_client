part of '../operation.dart';

///
/// Application System Diagnosis structure
final class SysDiag extends Operation {
  SysDiag.fromJsonMap(Map<String, dynamic> map): super._();
  //
  @override
  OperationId id() => OperationId.sysDiag;
}
///
/// Motor Temperature
final class MotorTemperature extends Operation implements OperationRender<EditActions> {
  final Map<String, dynamic> _map;
  MotorTemperature.fromJsonMap(Map<String, dynamic> map): 
    _map = map,
    super._();
  //
  @override
  Widget render(BuildContext context, {EditActions? actions}) {
    return EditWidget(
      actions: actions,
      text: _map['value'] ?? 'Temperature.render | Missed field "value"',
    );
  }
  //
  @override
  OperationId id() => OperationId.temperature;
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
  Widget render(BuildContext context, {OperationActions? actions}) {
    return Text(_map['value'] ?? 'Temperature.render | Missed field "value"');
  }
  //
  @override
  OperationId id() => OperationId.torque;
}
///
/// PressureState
final class PressureState extends Operation {
  PressureState.fromJsonMap(Map<String, dynamic> map): super._();
  //
  @override
  OperationId id() => OperationId.pressureState;
}
///
/// MotorSpeed
final class MotorSpeed extends Operation {
  MotorSpeed.fromJsonMap(Map<String, dynamic> map): super._();
  //
  @override
  OperationId id() => OperationId.motorSpeed;
}
///
/// MotorCurrent
final class MotorCurrent extends Operation {
  MotorCurrent.fromJsonMap(Map<String, dynamic> map): super._();
  //
  @override
  OperationId id() => OperationId.motorCurrent;
}
///
/// FilePdf
final class FilePdf extends Operation {
  FilePdf.fromBytes(List<int> bytes): super._();
  //
  @override
  OperationId id() => OperationId.filePdf;
}
///
/// FileHtml
final class FileHtml extends Operation {
  FileHtml.fromBytes(List<int> bytes): super._();
  //
  @override
  OperationId id() => OperationId.fileHtml;
}
