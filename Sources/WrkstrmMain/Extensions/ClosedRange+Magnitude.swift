public extension Range where Range.Bound: BinaryFloatingPoint & Comparable {

  var magnitude: Bound { upperBound - lowerBound }
}

public extension ClosedRange where ClosedRange.Bound: BinaryFloatingPoint & Comparable {

  var magnitude: Bound { upperBound - lowerBound }
}
