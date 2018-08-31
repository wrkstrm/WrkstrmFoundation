import Foundation

public indirect enum Node<A: Equatable> {

    case single(A, next: Node<A>?)

    case double(previous: Node<A>?, node: A, next: Node<A>?)
}

extension Node: Sequence {

    public typealias Iterator = NodeIterator<A>

    public func makeIterator() -> NodeIterator<A> {
        return NodeIterator(node: self)
    }
}

public struct NodeIterator<A: Equatable>: IteratorProtocol {

    public typealias Element = Node<A>

    var node: Node<A>?

    public mutating func next() -> Node<A>? {
        switch node {
        case let .single(_, next)?:
            node = next
            return next
        default:
            return nil
        }
    }
}

extension Node: Equatable {

    public static func == (lhs: Node<A>, rhs: Node<A>) -> Bool {
        switch lhs {
        case let .single(lhsElement, _):
            switch rhs {
            case let .single(rhsElement, _):
                return lhsElement == rhsElement
            default:
                return false
            }
        default:
            return false
        }
    }
}
