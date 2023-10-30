extension RandomAccessCollection {
  func indexed() -> IndexedCollection<Self> {
    IndexedCollection(base: self)
  }
}
