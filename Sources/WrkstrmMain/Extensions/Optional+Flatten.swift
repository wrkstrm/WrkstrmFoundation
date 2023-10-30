public protocol AnyFlattenable {
  /// Unwraps any value to potentially a nil base value
  func flattened() -> Any?
}

extension Optional: AnyFlattenable {
  public func flattened() -> Any? {
    switch self {
      case let .some(x as AnyFlattenable):
        x.flattened()

      case let .some(x):
        x

      case .none:
        nil
    }
  }
}
