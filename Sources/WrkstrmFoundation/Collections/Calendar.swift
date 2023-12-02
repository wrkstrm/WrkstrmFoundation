import Foundation
import WrkstrmMain

/// `Calendar` is a structure that represents a collection of events, each defined by a start and end date.
/// It stores `Event` instances in a `SortedArray`, ensuring they are always in chronological order based on their start date.
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

extension Calendar {
  /// `Event` is a structure representing a time-bound occurrence in the `Calendar`.
  /// It is `Comparable` and `Equatable` based on its start and end dates.
  public struct Event: Comparable, Equatable {
    /// Returns a Boolean value indicating whether the first event (`lhs`) starts before the second event (`rhs`).
    public static func < (lhs: Event, rhs: Event) -> Bool {
      lhs.start < rhs.start
    }

    /// The starting date of the event.
    public let start: Date

    /// The ending date of the event.
    public let end: Date

    /// A closed range representing the time interval of the event in seconds from 1970.
    public var interval: ClosedRange<TimeInterval> {
      start.timeIntervalSince1970...end.timeIntervalSince1970
    }

    /// Determines if the event overlaps with another event, considering an optional gap.
    /// - Parameters:
    ///   - other: The `Event` to compare with.
    ///   - gap: An optional time gap to consider between events. Defaults to 0.
    /// - Returns: `true` if there is an overlap; otherwise, `false`.
    public func overlaps(_ other: Event, gap: Double = 0) -> Bool {
      let adjustedStart = other.start.timeIntervalSince1970.advanced(by: -gap)
      let adjustedEnd = other.end.timeIntervalSince1970.advanced(by: gap)
      return interval.overlaps(adjustedStart...adjustedEnd)
    }

    /// Alternative method to determine overlap using the interval computed property.
    /// - Parameters:
    ///   - computed: The `Event` to compare with.
    ///   - gap: An optional time gap to consider between events. Defaults to 0.
    /// - Returns: `true` if there is an overlap; otherwise, `false`.
    public func overlaps(computed other: Event, gap: Double = 0) -> Bool {
      interval.contains(other.start.timeIntervalSince1970.advanced(by: -gap))
        || interval.contains(other.end.timeIntervalSince1970.advanced(by: gap))
    }

    /// Alternative method to determine overlap by manually checking start and end dates.
    /// - Parameters:
    ///   - manually: The `Event` to compare with.
    ///   - gap: An optional time gap to consider between events. Defaults to 0.
    /// - Returns: `true` if there is an overlap; otherwise, `false`.
    public func overlaps(manually other: Event, gap: Double = 0) -> Bool {
      (start >= other.start.addingTimeInterval(-gap) && start <= other.end.addingTimeInterval(gap))
        || (end >= other.start.addingTimeInterval(-gap) && end <= other.end.addingTimeInterval(gap))
    }

    /// Provides a string representation of the event's start and end dates.
    public var description: String {
      "[\(DateFormatter.mediumDate.string(from: start)) "
        + " -\(DateFormatter.mediumDate.string(from: end))]"
    }
  }
}

extension Calendar.Event {
  /// Initializes a new `Event` with a random start date and a fixed duration.
  /// - Parameter startDate: The starting date of the event. Defaults to a random date within a range.
  public init(startDate: Date = Date(timeIntervalSinceNow: .random(in: 0...Double(200_000_000)))) {
    start = startDate
    end = Date(timeIntervalSinceNow: start.timeIntervalSinceNow + 100_000)
  }
}
