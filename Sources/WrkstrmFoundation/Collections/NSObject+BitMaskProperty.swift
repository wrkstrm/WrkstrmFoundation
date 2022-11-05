import Foundation
import WrkstrmMain

extension NSObject {
  
  /// Sets a bit mask to a property on an object.
  public func property(_ property: String, set: [UInt], clear: [UInt]) {
    guard let value = value(forKey: property) as? UInt else {
      print("property (\(property)) cannot be interpreted as an UInt.")
      return
    }
    setValue((value & ~UInt.bitSet(clear)) | UInt.bitSet(set), forKey: property)
  }
}
