import Foundation
import WrkstrmMain

// Keep Foundation coupling/defaults here; core Parser lives in WrkstrmMain.
extension WrkstrmMain.JSON.Parser {
  /// Foundation-backed defaults (camelCase keys, robust date handling).
  public static var foundationDefault: WrkstrmMain.JSON.Parser {
    .init(encoder: JSONEncoder.commonDateFormatting, decoder: JSONDecoder.commonDateParsing)
  }
}
