import 'package:hmi_core/hmi_core_failure.dart';
import 'package:hmi_core/hmi_core_result.dart';

///
/// Field [Content] used to specify the kind of content stored in `Event`.
/// Sent request and returned response shouldn't have same [Content].
enum Content {
    // any,       // 00;
    // bool,      // 08;
    bytes,     // 02;
    // duration,  // 49;
    empty,     // 01;
    // f32,       // 32;
    // f64,       // 33;
    // i16,       // 24;
    // i32,       // 25;
    // i64,       // 26;
    json;      // 38;
    // string,    // 40;
    // timestamp, // 48;
    // u16,       // 16;
    // u32,       // 17;
    // u64;       // 18;
    ///
    /// Returns [Content] parsed from int value
    /// - `empty` = 01
    /// - `bytes` = 02
    /// - `json`  = 38
    static Result<Content, Failure> fromInt(int val) {
      return switch (val) {
        01 => Ok(Content.empty),
        02 => Ok(Content.bytes),
        38 => Ok(Content.json),
        _ => Err(Failure('Content.fromInt | Unknown cot value $val, expected: 1, 2, 38')),
      };
    }
}
