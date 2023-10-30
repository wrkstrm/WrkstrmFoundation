extension Collection where Element: Comparable, Index == Int {
  // MARK: - Binary Search

  public func search(key: Element) -> Int? {
    var lowerBound = startIndex
    var upperBound = endIndex

    while lowerBound < upperBound {
      let mid = index(lowerBound, offsetBy: (upperBound - lowerBound) / 2)
      if self[mid] == key {
        return mid
      } else if self[mid] < key {
        lowerBound = mid + 1
      } else {
        upperBound = mid
      }
    }
    return nil
  }

  // MARK: - Merge Sort

  public func mergeSort() -> [Element] {
    guard count > 1 else { return Array(self) }

    let midIndex = startIndex + (endIndex - startIndex) / 2
    let left = self[startIndex..<midIndex].mergeSort()
    let right = self[midIndex..<endIndex].mergeSort()

    return merge(left: left, right: right)
  }

  private func merge<T: Comparable>(left: [T], right: [T]) -> [T] {
    var mergedArray = ArraySlice<T>()

    var left = ArraySlice(left)
    var right = ArraySlice(right)

    while !left.isEmpty, !right.isEmpty {
      if left.first! < right.first! {  // swiftlint:disable:this force_unwrapping
        mergedArray.append(left.removeFirst())
      } else {
        mergedArray.append(right.removeFirst())
      }
    }
    return Array(mergedArray + left + right)
  }
}
