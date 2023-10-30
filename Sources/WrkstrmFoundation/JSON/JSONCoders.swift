import Foundation

extension JSONDecoder {
  public static let `default` = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom(Decoding.customDateDecoder)
    return decoder
  }()
}

extension JSONEncoder {
  public static let `default` = { () -> JSONEncoder in
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom(Encoding.customDateEncoder)
    return encoder
  }()
}

private enum Encoding {
  static func customDateEncoder(date: Date, encoder: Encoder) throws {
    let stringDate = DateFormatter.iso8601.string(from: date)
    var container = encoder.singleValueContainer()
    try container.encode(stringDate)
  }
}

private enum Decoding {
  static func customDateDecoder(_ decoder: Decoder) throws -> Date {
    let dateString = try decoder.singleValueContainer().decode(String.self)
    if let date = DateFormatter.iso8601.date(from: dateString) {
      return date
    }
    if dateString.last == Character("Z"), let date = DateFormatter.iso8601Z.date(from: dateString) {
      return date
    }
    if dateString.count == 8, let date = DateFormatter.dateOnlyEncoder.date(from: dateString) {
      return date
    }
    let error =
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Error Decoding Date \(dateString)")
    throw DecodingError.valueNotFound(Date.self, error)
  }
}
