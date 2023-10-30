import Foundation
import WrkstrmMain

public struct Calendar {
  var events = SortedArray<Event>(unsorted: [Event](), sortOrder: <)

  mutating func insert(_ event: Event) {
    events.insert(event)
  }
}

extension Calendar {
  public struct Event: Comparable, Equatable {
    public static func < (lhs: Event, rhs: Event) -> Bool {
      lhs.start < rhs.start
    }

    public let start: Date

    public let end: Date

    public var interval: ClosedRange<TimeInterval> {
      start.timeIntervalSince1970...end.timeIntervalSince1970
    }

    public func overlaps(_ other: Event, gap: Double = 0) -> Bool {
      let adjustedStart = other.start.timeIntervalSince1970.advanced(by: -gap)
      let adjustedEnd = other.end.timeIntervalSince1970.advanced(by: gap)
      return interval.overlaps(adjustedStart...adjustedEnd)
    }

    /// Using interval computed property.
    public func overlaps(computed other: Event, gap: Double = 0) -> Bool {
      interval.contains(other.start.timeIntervalSince1970.advanced(by: -gap))
        || interval.contains(other.end.timeIntervalSince1970.advanced(by: gap))
    }

    /// Manually checking start and end.
    public func overlaps(manually other: Event, gap: Double = 0) -> Bool {
      (start >= other.start.addingTimeInterval(-gap) && start <= other.end.addingTimeInterval(gap))
        || (end >= other.start.addingTimeInterval(-gap) && end <= other.end.addingTimeInterval(gap))
    }

    public var description: String {
      "[\(DateFormatter.mediumDate.string(from: start)) "
        + " -\(DateFormatter.mediumDate.string(from: end))]"
    }
  }
}

extension Calendar.Event {
  public init(startDate: Date = Date(timeIntervalSinceNow: .random(in: 0...Double(200_000_000)))) {
    start = startDate
    end = Date(timeIntervalSinceNow: start.timeIntervalSinceNow + 100_000)
  }
}
