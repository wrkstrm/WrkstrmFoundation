import Foundation

public indirect enum List<A: Equatable> {

    case single(A, next: List<A>?)

    case double(previous: List<A>?, current: A, next: List<A>?)
}

extension List: Sequence {

    public typealias Iterator = ListIterator<A>

    public func makeIterator() -> Iterator {
        return Iterator(list: self)
    }
}

public struct ListIterator<A: Equatable>: IteratorProtocol {

    public typealias Element = List<A>

    var list: List<A>?

    public mutating func next() -> List<A>? {
        switch list {
        case let .single(_, next)?:
            list = next
            return next
        default:
            return nil
        }
    }
}

extension List: Equatable {

    public static func == (lhs: List<A>, rhs: List<A>) -> Bool {
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
