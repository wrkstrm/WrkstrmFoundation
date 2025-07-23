import WrkstrmMain

#if os(Linux)
  // Necessary import for Linux due to DispatchQueue not being Sendable.
  @preconcurrency import Foundation
#else
  import Foundation
#endif

/// Extensions to the `WrkstrmMain.JSON` namespace to provide additional JSON value representations.
extension WrkstrmMain.JSON {
  /// An enum representing arrays with equatable functionality.
  ///
  /// This enum provides a way to handle arrays in a type-safe manner with the capability
  /// of equality comparison. It includes various cases for different types of arrays
  /// that can be encountered in JSON data.
  public enum AnyEquatableArrayEnum: Equatable {
    /// Represents a generic array of `Any` type.
    case any([Any])

    /// Represents an array of dictionaries, with each dictionary conforming to
    /// `JSON.AnyDictionary`.
    case dictionary([JSON.AnyDictionary])

    /// A static method to compare two `AnyEquatableArrayEnum` values.
    /// Currently, this implementation always returns `true`.
    public static func == (_: Self, _: Self) -> Bool { true }
  }

  /// An enum representing dictionaries with equatable functionality.
  ///
  /// This enum is designed to handle dictionaries in JSON with equatable capabilities,
  /// allowing for comparison operations.
  public enum AnyEquatableDictionaryEnum: Equatable {
    /// Represents a dictionary of type `JSON.AnyDictionary`.
    case any(JSON.AnyDictionary)

    /// A static method to compare two `AnyEquatableDictionaryEnum` values.
    /// Currently, this implementation always returns `true`.
    public static func == (_: Self, _: Self) -> Bool { true }
  }

  /// An enum representing various types of JSON values, each associated with a key.
  ///
  /// This enum is useful for representing and handling different kinds of JSON values
  /// in a type-safe manner. Each case is associated with a string key and a value of
  /// a specific type.
  public enum KVPair: Equatable {
    /// Represents an integer value associated with a string key.
    case integer(String, Int)

    /// Represents a double value associated with a string key.
    case double(String, Double)

    /// Represents a string value associated with a string key.
    case string(String, String)

    /// Represents a date value associated with a string key.
    case date(String, Date)

    /// Represents an array value associated with a string key.
    case array(String, JSON.AnyEquatableArrayEnum)

    /// Represents a dictionary value associated with a string key.
    case dictionary(String, JSON.AnyEquatableDictionaryEnum)

    /// Represents a generic value associated with a string key.
    case any(String, String)
  }
}
