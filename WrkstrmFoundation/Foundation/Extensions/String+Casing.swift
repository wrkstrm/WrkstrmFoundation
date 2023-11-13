//
//  String+Utilities.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/8/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

extension String: Error {}

public extension String {

    func titlecased() -> String {
        return replacingOccurrences(of: "([A-Z])",
                                    with: " $1",
                                    options: .regularExpression,
                                    range: self.range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }
}
