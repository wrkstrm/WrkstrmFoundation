/// A generic struct that aides in sorting.
public struct Sort<Type> {

  // MARK: - Typealias

  /// A sort comparator function signature alias.
  public typealias Comparator = (Type, Type) -> Bool

  public typealias Property<P: Comparable> = (Type) -> P

  // MARK: - Initializers

  /// Convinience initializer for an ascending sort struct. (A, B, C...)
  @_specialize(where Type: _NativeClass, P: _Trivial)
  public static func ascending(_ ascending: @escaping Property<some Comparable>) -> Sort<Type> {
    Self(ascending: ascending)
  }

  /// Convinience initializer for an descending sort struct. (...3, 2, 1)
  @_specialize(where Type: _NativeClass, P: _Trivial)
  public static func descending(_ descending: @escaping Property<some Comparable>) -> Sort<Type> {
    Self(descending: descending)
  }

  let comparator: Comparator

  @_specialize(where Type: _NativeClass, P: _Trivial)
  public init(ascending: @escaping Property<some Comparable>) {
    comparator = { ascending($0) < ascending($1) }
  }

  @_specialize(where Type: _NativeClass, P: _Trivial)
  public init(descending: @escaping Property<some Comparable>) {
    comparator = { descending($0) > descending($1) }
  }

  // MARK: - Comparator Generators

  /// A convinience comparator creator given a comparable property.
  @_specialize(where Type: _NativeClass, P: _Trivial)
  public static func by(ascending: Bool = true,
                        _ property: @escaping Property<some Comparable>)
    -> Comparator
  {
    if ascending {
      { property($0) < property($1) }
    } else {
      { property($0) > property($1) }
    }
  }

  /// A convinience comparator combinator given an array of simple comparators.
  @_specialize(where Type: _NativeClass)
  public static func by(_ comparators: [Comparator]) -> Comparator {
    {  // swiftlint:disable:this opening_brace
      for comparator in comparators {
        if comparator($0, $1) { return true }
        if comparator($1, $0) { return false }
      }
      return false
    }
  }

  /// A sort struct combinator. Takes in a sequence of Sort structs and returns one comparator
  /// function.
  @_specialize(where Type: _NativeClass)
  public static func by(_ comparators: Sort<Type>...) -> Comparator {
    {  // swiftlint:disable:this opening_brace
      for order in comparators {
        if order.comparator($0, $1) { return true }
        if order.comparator($1, $0) { return false }
      }
      return false
    }
  }

  /// A sort struct combinator. Takes in an array of Sort structs and returns one comparator
  /// function.
  @_specialize(where Type: _NativeClass)
  public static func by(_ comparators: [Sort<Type>]) -> Comparator {
    {  // swiftlint:disable:this opening_brace
      for order in comparators {
        if order.comparator($0, $1) { return true }
        if order.comparator($1, $0) { return false }
      }
      return false
    }
  }
}
