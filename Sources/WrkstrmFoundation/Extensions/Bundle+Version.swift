import Foundation

public extension Bundle {

  static var mainAppVersion: String {
    "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "") "
      + "Build: (\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""))"
  }
}
