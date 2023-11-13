//
//  Injectable.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/7/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public protocol Injectable {

    associatedtype Resource

    func inject(_ resource: Resource)

    func assertDependencies()
}
