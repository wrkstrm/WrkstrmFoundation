#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif
import WrkstrmMain

public enum JSON {
  public enum EquatableArray: Equatable {
    case any([Any])

    case dictionary([JSONDictionary])

    public static func == (_: EquatableArray, _: EquatableArray) -> Bool { true }
  }

  public enum EquatableDictionary: Equatable {
    case any(JSONDictionary)

    public static func == (_: EquatableDictionary, _: EquatableDictionary) -> Bool { true }
  }

  public enum Value: Equatable {
    case integer(String, Int)

    case double(String, Double)

    case string(String, String)

    case date(String, Date)

    case array(String, EquatableArray)

    case dictionary(String, EquatableDictionary)

    case any(String, String)
  }
}
