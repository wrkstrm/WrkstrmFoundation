//
//  Registrar.swift
//  WrkstrmUtilities
//
//  Created by Cristian Monterroza on 7/8/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public struct Registrar {

    public var classes: [ReusableCell.Type]?

    public var nibs: [ReusableCell.Type]?

    public init(classes: [ReusableCell.Type]? = nil, nibs: [ReusableCell.Type]? = nil) {
        self.classes = classes
        self.nibs = nibs
    }
}
