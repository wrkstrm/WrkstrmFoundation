import Foundation

extension Date {
    /// Initializes a `Date` instance from a string formatted according to a Git log timestamp.
    /// This initializer uses `DateFormatter.gitLog` to parse the provided string.
    ///
    /// The Git log timestamp format is expected to be the one defined in `DateFormatter.gitLog`.
    /// If the string does not conform to this format, the initializer will fail and return `nil`.
    ///
    /// - Parameter gitLogString: A string representing a date in the Git log timestamp format.
    /// - Returns: An optional `Date` instance. If the string can be successfully parsed, it returns the corresponding `Date`. Otherwise, it returns `nil`.
    public init?(gitLogString: String) {
        guard let date = DateFormatter.gitLog.date(from: gitLogString) else {
            return nil
        }
        self = date
    }
}
