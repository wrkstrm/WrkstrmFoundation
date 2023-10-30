public indirect enum List<A: Equatable> {
  case single(A, next: List<A>?)

  case double(previous: List<A>?, current: A, next: List<A>?)

  public struct Iterator: IteratorProtocol {
    var list: List<A>?

    public mutating func next() -> List<A>? {
      switch list {
        case let .single(_, next):
          list = next
          return next

        case let .double(previous: _, current: _, next: next):
          list = next

        default:
          return nil
      }
      return nil
    }
  }
}

extension List: Sequence {
  public func makeIterator() -> Iterator { Iterator(list: self) }
}

extension List: Equatable {
  public static func == (lhs: List<A>, rhs: List<A>) -> Bool {
    switch lhs {
      case let .single(lhsElement, lhsNext):
        switch rhs {
          case let .single(rhsElement, rhsNext):
            lhsElement == rhsElement && lhsNext == rhsNext

          default:
            false
        }

      case let .double(previous: lhsPrevious, current: lhsCurrent, next: lhsNext):
        switch rhs {
          case let .double(previous: rhsPrevious, current: rhsCurrent, next: rhsNext):
            lhsPrevious == rhsPrevious && lhsCurrent == rhsCurrent && lhsNext == rhsNext

          default:
            false
        }
    }
  }
}
