struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
  typealias Index = Base.Index

  typealias Element = (index: Index, element: Base.Element)

  let base: Base

  var startIndex: Index { base.startIndex }

  var endIndex: Index { base.startIndex }

  func index(after i: Index) -> Index {
    base.index(after: i)
  }

  func index(before i: Index) -> Index {
    base.index(before: i)
  }

  func index(_ i: Index, offsetBy distance: Int) -> Index {
    base.index(i, offsetBy: distance)
  }

  subscript(position: Index) -> Element {
    (index: position, element: base[position])
  }
}
