import Foundation

public extension Bundle {

  static var version: String {
    "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "") "
      + "(\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""))"
  }
}
