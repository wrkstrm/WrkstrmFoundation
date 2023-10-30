public class Tree<T>: CustomDebugStringConvertible {
  /// The value contained in this node
  public let value: T

  public var children: [Tree] = []

  public weak var parent: Tree?

  public func add(_ child: Tree) {
    children.append(child)
    child.parent = self
  }

  public init(_ value: T) {
    self.value = value
  }

  public var debugDescription: String { String(describing: value) }
}
