import WrkstrmMain

#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension WrkstrmMain.JSON {
  public enum AnyEquatableArrayEnum: Equatable {
    case any([Any])

    case dictionary([WrkstrmMain.JSON.Dictionary])

    public static func == (_: Self, _: Self) -> Bool { true }
  }

  public enum AnyEquatableDictionaryEnum: Equatable {
    case any(WrkstrmMain.JSON.Dictionary)

    public static func == (_: Self, _: Self) -> Bool { true }
  }

  public enum Value: Equatable {
    case integer(String, Int)

    case double(String, Double)

    case string(String, String)

    case date(String, Date)

    case array(String, JSON.AnyEquatableArrayEnum)

    case dictionary(String, JSON.AnyEquatableDictionaryEnum)

    case any(String, String)
  }
}
