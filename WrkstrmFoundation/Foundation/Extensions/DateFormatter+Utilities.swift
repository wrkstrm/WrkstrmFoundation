//
//  DateFormatter+Utilities.swift
//  WrkstrmUtilities
//
//  Created by Cristian Monterroza on 7/8/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public extension DateFormatter {

    public static let dateOnlyEncoder = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    public static let mediumDate = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    public static let iso8601 = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
        return formatter
    }()
}

public extension Date {

    public func localizedString(with style: DateFormatter.Style = .medium) -> String {
        switch style {
        case .medium:
            return DateFormatter.mediumDate.string(from: self)
        default:
            return DateFormatter.mediumDate.string(from: self)
        }
    }
}
