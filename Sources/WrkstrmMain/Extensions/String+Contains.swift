public extension String {

  func containsUniqueChars() -> Bool {
    var set = Set<Character>()
    for character in self {
      if set.contains(character) {
        return false
      } else {
        set.insert(character)
      }
    }
    return true
  }

  func isPermutation(_ other: String) -> Bool {
    guard count == other.count else { return false }
    return unicodeScalars.reduce(0) { $0 + $1.value }
      == other.unicodeScalars.reduce(0) { $0 + $1.value }
  }
}
