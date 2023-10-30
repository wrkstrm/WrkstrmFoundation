class BinaryTree<Value: Comparable> {
  private(set) var value: Value
  private(set) var parent: BinaryTree?
  private(set) var left: BinaryTree?
  private(set) var right: BinaryTree?

  init(_ value: Value) {
    self.value = value
  }

  private init(_ value: Value, parent: BinaryTree?) {
    self.value = value
    self.parent = parent
  }

  public var isRoot: Bool { parent == nil }

  public var isLeaf: Bool { left == nil && right == nil }

  public var hasLeftChild: Bool { left != nil }

  public var hasRightChild: Bool { right != nil }

  public var count: Int { (left?.count ?? 0) + 1 + (right?.count ?? 0) }

  @discardableResult public func insert(_ value: Value) -> BinaryTree {
    guard value < self.value else {
      if let right {
        right.insert(value)
      } else {
        right = BinaryTree(value, parent: self)
      }
      return right!  // swiftlint:disable:this force_unwrapping
    }
    if let left {
      left.insert(value)
    } else {
      left = BinaryTree(value, parent: self)
    }
    return left!
  }

  enum Order {
    case pre
    case `in`  // swiftlint:disable:this identifier_name
    case post
  }

  public func traverse(_ order: Order = .in, block: (BinaryTree) -> Void) {
    switch order {
      case .pre:
        block(self)
        left?.traverse(block: block)
        right?.traverse(block: block)

      case .in:
        left?.traverse(block: block)
        block(self)
        right?.traverse(block: block)

      case .post:
        left?.traverse(block: block)
        right?.traverse(block: block)
        block(self)
    }
  }
}
