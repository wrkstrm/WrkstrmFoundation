import Foundation

extension Bundle {
  public static var mainAppVersion: String {
    "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "") "
      + "Build: (\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""))"
  }
}
