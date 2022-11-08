public extension UInt {

  /// Sets the bits to a bit mask and returns it's value
  static func bitSet(_ bits: [UInt]) -> UInt {
    bits.reduce(0) { $0 | (1 << $1) }
  }
}
