extension Range where Range.Bound: BinaryFloatingPoint & Comparable {
  public var magnitude: Bound { upperBound - lowerBound }
}

extension ClosedRange where ClosedRange.Bound: BinaryFloatingPoint & Comparable {
  public var magnitude: Bound { upperBound - lowerBound }
}
