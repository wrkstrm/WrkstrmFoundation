#if os(Linux)
// Required due to the lack of DispatchQueue being Sendable on Linux platforms.
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Bundle {
  /// Retrieves the main application's version and build number from the Info.plist.
  ///
  /// This property concatenates the app's version number (CFBundleShortVersionString) and build number
  /// (CFBundleVersion) into a single string, formatted as "Version: [version] Build: ([build])".
  /// If either value is not found, it defaults to an empty string.
  ///
  /// Usage:
  /// ```swift
  /// let appVersion = Bundle.mainAppVersion
  /// print(appVersion) // Output: "Version: 1.0 Build: (1)"
  /// ```
  ///
  /// Note: This extension is particularly useful for settings screens, about dialogs, or logging.
  public static var mainAppVersion: String {
    "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "") "
      + "Build: (\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""))"
  }
}
