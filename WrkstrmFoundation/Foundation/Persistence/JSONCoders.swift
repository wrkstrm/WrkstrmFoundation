//
//  Encoders.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 8/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

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
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601)
        return encoder
    }()
}

private struct Decoding {

    static func customDateDecoder(_ decoder: Decoder) throws -> Date {
        let dateString = try decoder.singleValueContainer().decode(String.self)
        if dateString.count == 8 {
            if let date = DateFormatter.dateOnlyEncoder.date(from: dateString) {
                return date
            }
        }
        if let date = DateFormatter.iso8601.date(from: dateString) {
            return date
        }
        throw DecodingError.valueNotFound(Date.self,
                                          DecodingError.Context(codingPath: decoder.codingPath,
                                                                debugDescription: "Error Parsing Date \(dateString)"))
    }
}
