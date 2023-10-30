extension Sequence {
  // MARK: - Decompose

  public func decomposeFirst(with predicate: (Element) -> Bool) -> (Element?, [Element]) {
    var first: Element?
    var others: [Element] = []
    var iterator = makeIterator()
    while let item = iterator.next() {
      if first == nil, predicate(item) {
        first = item
      } else {
        others.append(item)
      }
    }
    return (first, others)
  }

  public func decompose() -> (Element?, [Element]) {
    decomposeFirst { _ in true }
  }

  public func decomposeAll(with predicate: (Element) -> Bool) -> ([Element]?, [Element]) {
    var all: [Element] = []
    var others: [Element] = []
    var iterator = makeIterator()
    while let item = iterator.next() {
      if predicate(item) {
        all.append(item)
      } else {
        others.append(item)
      }
    }
    return (all.isEmpty ? nil : all, others)
  }

  public func decomposeUntil(with predicate: (Element) -> Bool) -> ([Element]?, [Element]) {
    var all: [Element] = []
    var others: [Element] = []
    var iterator = makeIterator()
    var continueAccumulation = true
    while let item = iterator.next() {
      if predicate(item), continueAccumulation {
        all.append(item)
      } else {
        continueAccumulation = false
        others.append(item)
      }
    }
    return (all.isEmpty ? nil : all, others)
  }

  // MARK: - Contain

  public func allMatch(_ predicate: (Element) -> Bool) -> Bool {
    !contains { !predicate($0) }
  }

  public func noneMatch(_ predicate: (Element) -> Bool) -> Bool {
    !contains { predicate($0) }
  }

  // MARK: - Batching

  public func batches(by predicate: ([Element], Element) -> Bool) -> [[Element]] {
    var all: [[Element]] = []
    var batch: [Element] = []
    var iterator = makeIterator()
    while let item = iterator.next() {
      if !predicate(batch, item) {
        all.append(batch)
        batch = [Element]()
      }
      batch.append(item)
    }
    all.append(batch)
    return all
  }

  public func split(batchSize: Int) -> [[Element]] {
    batches { batch, _ in batch.count < batchSize }
  }
}
