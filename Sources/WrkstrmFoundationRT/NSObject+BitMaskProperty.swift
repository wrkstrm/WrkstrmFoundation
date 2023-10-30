import Foundation
import WrkstrmLog
import WrkstrmMain

extension NSObject {
  /// Sets a bit mask to a property on an object.
  public func property(_ property: String, set: [UInt], clear: [UInt]) {
    guard let value = self.value(forKey: property) as? UInt else {
      Log.verbose("property (\(property)) cannot be interpreted as an UInt.")
      return
    }
    self.setValue((value & ~UInt.bitSet(clear)) | UInt.bitSet(set), forKey: property)
  }
}
