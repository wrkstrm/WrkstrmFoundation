import XCTest

@testable import WrkstrmMain

#if canImport(UIKit)
import UIKit
#endif

final class BinaryTreeTests: XCTestCase {
  static var allTests = [
    ("testBasicInsertion", testBasicInsertion),
    ("testRandomTreeCount", testRandomTreeCount),
  ]

  var tree = BinaryTree(1)

  func testBasicInsertion() {
    tree.insert(3)
    tree.insert(5)
    tree.insert(7)
    tree.insert(1)
    tree.insert(0)
    tree.insert(20)
    tree.insert(11)  // Count == 8
    XCTAssertTrue(tree.count == 8)
  }

  func testRandomTreeCount() {
    let randomTree = BinaryTree(1)
    let randomCount = Int.random(in: 0...10)
    (0..<randomCount).forEach { _ in
      randomTree.insert(Int.random(in: 0...10))
    }
    XCTAssertTrue(randomTree.count == (randomCount + 1))
  }
}
