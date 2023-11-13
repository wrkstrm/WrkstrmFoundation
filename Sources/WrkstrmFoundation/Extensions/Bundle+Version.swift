#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Bundle {
  public static var mainAppVersion: String {
    "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "") "
      + "Build: (\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""))"
  }
}
