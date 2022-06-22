import UIKit
@testable import WrkstrmFoundation
import XCTest

final class BinaryTreeTests: XCTestCase {

  static var allTests = [
    ("testBasicInsertion", testBasicInsertion),
    ("testRandomTreeCount", testRandomTreeCount),
  ]

  var tree = BinaryTree(1)

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

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
    // Index starts at 1 because starting at 0 would add an extra element
    // For example, 0..2, adds 3 elements instead of 2.
    (1...randomCount).forEach { _ in
      randomTree.insert(Int.random(in: 0...10))
    }
    XCTAssertTrue(randomTree.count == (randomCount + 1))
  }
}