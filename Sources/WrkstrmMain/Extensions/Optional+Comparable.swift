extension Optional: Comparable where Wrapped: Equatable & Comparable {

  public static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
      return l < r

    case (nil, _?):
      return true

    default:
      return false
    }
  }
}
