// This functionality relies on `RelativeDateTimeFormatter`, which is not
// implemented on Linux. Compile this extension only for non-Linux platforms.
#if !os(Linux)
  import Foundation

  extension RelativeDateTimeFormatter {
    /// Returns a non breaking localized string describing the relative time between the provided
    /// timestamp and now.
    ///
    /// This method converts a Unix timestamp into a human-readable relative time string
    /// (e.g., "2 hours ago", "yesterday"). The output string uses non-breaking spaces to prevent
    /// unwanted line breaks in the formatted text.
    ///
    /// - Parameter timeIntervalSince1970: Unix timestamp (seconds since January 1, 1970)
    /// - Returns: A localized string representing the relative time with non-breaking spaces
    ///
    /// - Note: The returned string replaces regular spaces with non-breaking spaces (`\u{00A0}`)
    ///
    /// - Example:
    ///   ```swift
    ///   let timestamp = 1634567890
    ///   let relative = formatter.creationRelativeToNow(for: timestamp)
    ///   // Returns something like "2\u{00A0}hours\u{00A0}ago"
    ///   ```
    public func nonBreakingCreationRelativeToNow(for timeIntervalSince1970: TimeInterval) -> String
    {
      localizedString(for: Date(timeIntervalSince1970: timeIntervalSince1970), relativeTo: Date())
        .replacingOccurrences(
          of: " ",
          with: "\u{00A0}",
        )
    }
  }
#endif  // !os(Linux)
