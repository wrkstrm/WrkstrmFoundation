import Foundation
import WrkstrmMain

/// A lightweight, generic instrumentation wrapper that decorates a concrete implementation
/// and optionally records performance events.
///
/// Use `Instrumented<Base>` directly, or the convenience alias `JSONInstrumented<Base>` when
/// wrapping JSON encoders/decoders.
public struct Instrumented<Base>: @unchecked Sendable {
  public let base: Base
  public let name: String
  public let context: String?
  public let recorder: JSON.ParseMetricsStore?

  public init(
    base: Base,
    name: String,
    context: String? = nil,
    recorder: JSON.ParseMetricsStore? = nil
  ) {
    self.base = base
    self.name = name
    self.context = context
    self.recorder = recorder
  }
}

/// Convenience alias for JSON-related instrumentation wrappers.
public typealias JSONInstrumented<Base> = Instrumented<Base>

// MARK: - JSONDataEncoding/Decoding conformances

extension Instrumented: JSONDataEncoding where Base: JSONDataEncoding {
  public func encode<T: Encodable>(_ value: T) throws -> Data {
    let start = DispatchTime.now().uptimeNanoseconds
    do {
      let data = try base.encode(value)
      let ns = Int64(DispatchTime.now().uptimeNanoseconds &- start)
      if let recorder {
        let event = JSON.ParseMetricEvent(
          op: .encode,
          typeName: String(describing: T.self),
          parserName: name,
          sizeBytes: data.count,
          durationNanoseconds: ns,
          success: true,
          context: context,
          errorDescription: nil
        )
        Task { await recorder.append(event) }
      }
      return data
    } catch {
      let ns = Int64(DispatchTime.now().uptimeNanoseconds &- start)
      if let recorder {
        let event = JSON.ParseMetricEvent(
          op: .encode,
          typeName: String(describing: T.self),
          parserName: name,
          sizeBytes: nil,
          durationNanoseconds: ns,
          success: false,
          context: context,
          errorDescription: String(describing: error)
        )
        Task { await recorder.append(event) }
      }
      throw error
    }
  }
}

extension Instrumented: JSONDataDecoding where Base: JSONDataDecoding {
  public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    let start = DispatchTime.now().uptimeNanoseconds
    do {
      let value = try base.decode(T.self, from: data)
      let ns = Int64(DispatchTime.now().uptimeNanoseconds &- start)
      if let recorder {
        let event = JSON.ParseMetricEvent(
          op: .decode,
          typeName: String(describing: T.self),
          parserName: name,
          sizeBytes: data.count,
          durationNanoseconds: ns,
          success: true,
          context: context,
          errorDescription: nil
        )
        Task { await recorder.append(event) }
      }
      return value
    } catch {
      let ns = Int64(DispatchTime.now().uptimeNanoseconds &- start)
      if let recorder {
        let event = JSON.ParseMetricEvent(
          op: .decode,
          typeName: String(describing: T.self),
          parserName: name,
          sizeBytes: data.count,
          durationNanoseconds: ns,
          success: false,
          context: context,
          errorDescription: String(describing: error)
        )
        Task { await recorder.append(event) }
      }
      throw error
    }
  }
}

// MARK: - Existential wrappers for `any` bases

/// Instrumentation wrapper for existential encoders.
public struct InstrumentedAnyEncoder: JSONDataEncoding, Sendable {
  public let base: any JSONDataEncoding
  public let name: String
  public let context: String?
  public let recorder: JSON.ParseMetricsStore?

  public init(
    base: any JSONDataEncoding,
    name: String,
    context: String? = nil,
    recorder: JSON.ParseMetricsStore? = nil
  ) {
    self.base = base
    self.name = name
    self.context = context
    self.recorder = recorder
  }

  public func encode<T: Encodable>(_ value: T) throws -> Data {
    let start = DispatchTime.now().uptimeNanoseconds
    do {
      let data = try base.encode(value)
      let ns = Int64(DispatchTime.now().uptimeNanoseconds &- start)
      if let recorder {
        let event = JSON.ParseMetricEvent(
          op: .encode,
          typeName: String(describing: T.self),
          parserName: name,
          sizeBytes: data.count,
          durationNanoseconds: ns,
          success: true,
          context: context,
          errorDescription: nil
        )
        Task { await recorder.append(event) }
      }
      return data
    } catch {
      let ns = Int64(DispatchTime.now().uptimeNanoseconds &- start)
      if let recorder {
        let event = JSON.ParseMetricEvent(
          op: .encode,
          typeName: String(describing: T.self),
          parserName: name,
          sizeBytes: nil,
          durationNanoseconds: ns,
          success: false,
          context: context,
          errorDescription: String(describing: error)
        )
        Task { await recorder.append(event) }
      }
      throw error
    }
  }
}

/// Instrumentation wrapper for existential decoders.
public struct InstrumentedAnyDecoder: JSONDataDecoding, Sendable {
  public let base: any JSONDataDecoding
  public let name: String
  public let context: String?
  public let recorder: JSON.ParseMetricsStore?

  public init(
    base: any JSONDataDecoding,
    name: String,
    context: String? = nil,
    recorder: JSON.ParseMetricsStore? = nil
  ) {
    self.base = base
    self.name = name
    self.context = context
    self.recorder = recorder
  }

  public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    let start = DispatchTime.now().uptimeNanoseconds
    do {
      let value = try base.decode(T.self, from: data)
      let ns = Int64(DispatchTime.now().uptimeNanoseconds &- start)
      if let recorder {
        let event = JSON.ParseMetricEvent(
          op: .decode,
          typeName: String(describing: T.self),
          parserName: name,
          sizeBytes: data.count,
          durationNanoseconds: ns,
          success: true,
          context: context,
          errorDescription: nil
        )
        Task { await recorder.append(event) }
      }
      return value
    } catch {
      let ns = Int64(DispatchTime.now().uptimeNanoseconds &- start)
      if let recorder {
        let event = JSON.ParseMetricEvent(
          op: .decode,
          typeName: String(describing: T.self),
          parserName: name,
          sizeBytes: data.count,
          durationNanoseconds: ns,
          success: false,
          context: context,
          errorDescription: String(describing: error)
        )
        Task { await recorder.append(event) }
      }
      throw error
    }
  }
}
