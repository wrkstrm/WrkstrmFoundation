import Foundation

extension String {
  public var fileType: String? {
    URL(fileURLWithPath: self).pathExtension
  }
}
