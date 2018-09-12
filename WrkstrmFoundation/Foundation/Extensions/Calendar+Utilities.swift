//
//  Calendar+Utilities.swift
//  wrkstrm
//
//  Created by Cristian Monterroza on 9/9/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

extension Calendar {

    static let `default` = Calendar(identifier: .gregorian)
}

extension Date {

    func component(_ component: Calendar.Component,
                   calendar: Calendar = Calendar.default) -> Int {
        return calendar.component(component, from: self)
    }
}
