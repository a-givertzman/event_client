import 'package:hmi_core/hmi_core_failure.dart';
import 'package:hmi_core/hmi_core_result.dart';

///
/// Cause and diraction of the transmission
/// - `Inf` - Information (Informational message, in general sent by backend to the client)
/// - `Act` - Activation (Command message, response is not required, optionally my be sent Cot::ActCon / Cot::ActErr)
/// - `ActCon` - Activation confirmatiom
/// - `ActErr` - Activation error
/// - `Req` - Request (Request message, Client expects response with Cot::ReqCon / Cot::ReqErr)
/// - `ReqCon` - Rquest | Confirmatiom reply 
/// - `ReqErr` - Rquest | Error reply
enum Cot {
  inf(02),
  act(04),
  actCon(08),
  actErr(16),
  req(32),
  reqCon(64),
  reqErr(128);
  // Holds a numeric representation
  final int value;
  /// Returns [Cot] new instance
  const Cot(this.value);
  ///
  /// Returns [Cot] parsed from int value
  /// - Inf    = 02  (0x02);
  /// - Act    = 04  (0x04);
  /// - ActCon = 08  (0x08);
  /// - ActErr = 16  (0x10);
  /// - Req    = 32  (0x20);
  /// - ReqCon = 64  (0x40);
  /// - ReqErr = 128 (0x80);
  static Result<Cot, Failure> fromInt(int val) {
    return switch (val) {
      002 => Ok(Cot.inf),
      004 => Ok(Cot.act),
      008 => Ok(Cot.actCon),
      016 => Ok(Cot.actErr),
      032 => Ok(Cot.req),
      064 => Ok(Cot.reqCon),
      128 => Ok(Cot.reqErr),
      _ => Err(Failure('Cot.fromInt | Unknown cot value $val, expected: 2, 4, 8, 16 ,32, 64, 128')),
    };
  }
}
