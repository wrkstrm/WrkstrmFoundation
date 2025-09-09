import Foundation
import WrkstrmMain

// Default conformances for Foundation JSON coders to top-level protocols.
extension JSONEncoder: JSONDataEncoding {}
extension JSONDecoder: JSONDataDecoding {}
