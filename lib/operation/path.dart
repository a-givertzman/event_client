// ignore_for_file: non_constant_identifier_names

///
/// ## Application DSL map for the `EventClient`
/// 
/// Providees the mapping of the events names in the string and structural variants:
/// 
/// ```dart
/// final client = EventClientProvider.of(context);
/// 
/// // subscribe on the stream by the event struct name
/// final Stream<Temperature> stream = client.stream<Temperature>(server.Device1.Temperature);
/// 
/// // subscribe on the stream by the event string name
/// final Stream<Temperature> stream = client.stream<Temperature>('/Server/Device1/Temperature');
/// ```
final server = (
  Device1: (
    MotorTemperature:       '/Server/Device1/Motor.Temperature',
    MotorSpeed:             '/Server/Device1/Motor.Speed',
  ),
  Device2: (
    MotorTemperature:       '/Server/Device2/MotorTemperature',
    WinchSpeed:             '/Server/Device2/Winch.Speed',
  ),
);