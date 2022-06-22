import Foundation

extension Bundle {

  public static var version: String {
    "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "") "
      + "(\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""))"
  }
}
