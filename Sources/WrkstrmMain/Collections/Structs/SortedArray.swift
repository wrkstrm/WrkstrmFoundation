public enum SearchResult<N: Numeric> {
  case found(at: N)

  case notFound(insertAt: N)
}

public struct SortedArray<Element>: Collection {
  public typealias Comparator<A> = (A, A) -> Bool

  public var elements: [Element]

  public let sortOrder: Comparator<Element>

  public mutating func insert(_ element: Element) {
    switch search(for: element) {
      case let .found(at: index):
        elements.insert(element, at: index)

      case let .notFound(insertAt: index):
        elements.insert(element, at: index)
    }
  }

  public init<S: Sequence>(
    unsorted: S,
    sortOrder: @escaping Comparator<S.Element>
  ) where S.Element == Element {
    elements = unsorted.sorted(by: sortOrder)
    self.sortOrder = sortOrder
  }

  public func search(for element: Element) -> SearchResult<Int> {
    var start = elements.startIndex
    var end = elements.endIndex

    while start < end {
      let mid = start + (end - start) / 2
      if sortOrder(elements[mid], element) {
        start = mid + 1
      } else if sortOrder(element, elements[mid]) {
        end = mid
      } else {
        return .found(at: mid)
      }
    }

    return .notFound(insertAt: start)
  }

  // MARK: - Collection Protocol

  public var startIndex: Int { elements.startIndex }

  public var endIndex: Int { elements.endIndex }

  public subscript(index: Int) -> Element { elements[index] }

  public func index(after i: Int) -> Int { elements.index(after: i) }

  public func min() -> Element? { elements.first }

  public func max() -> Element? { elements.last }
}

extension SortedArray where Element: Comparable {
  public init() {
    self.init(unsorted: [Element](), sortOrder: <)
  }

  public init(unsorted: some Sequence<Element>) {
    self.init(unsorted: unsorted, sortOrder: <)
  }
}

extension Array where Element: Comparable {
  public var sortedArray: SortedArray<Element> { SortedArray(unsorted: self) }
}
