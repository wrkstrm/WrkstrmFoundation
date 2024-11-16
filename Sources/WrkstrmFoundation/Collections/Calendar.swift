import Foundation
import WrkstrmMain

/// `Calendar` is a structure that represents a collection of events, each defined by a start and
/// end date.It stores `Event` instances in a `SortedArray`, ensuring they are always in
/// chronological order based on their start date.
public struct Calendar {
  /// A sorted array of `Event` objects.
  var events: SortedArray<Event> = .init(unsorted: [Event](), sortOrder: <)

  /// Inserts a new `Event` into the `Calendar`.
  /// The `Event` is added in chronological order based on its start date.
  /// - Parameter event: The `Event` to be inserted.
  mutating func insert(_ event: Event) {
    events.insert(event)
  }
}
