//
//  DateFormatter.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/8/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

extension NumberFormatter {

    public static let integer: NumberFormatter = { () -> NumberFormatter in
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    public static let double: NumberFormatter = { () -> NumberFormatter in
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        return formatter
    }()
}

public protocol LocalizedValues {

    func integerString() -> String
}

extension LocalizedValues {

    public func integerString() -> String {
        return NumberFormatter.integer.string(for: self)!
    }
}
extension Int: LocalizedValues { }

extension Double: LocalizedValues {

    public func doubleString() -> String {
        return NumberFormatter.double.string(for: self)!
    }
}
