//
//  Comparable+Swift.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/2/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

struct Sort<Type> {

    typealias Descriptor<Type> = (Type, Type) -> Bool

    static func by<Property: Comparable>(ascending: Bool = true,
                                         property: @escaping (Type) -> Property) -> Descriptor<Type> {
        return { property(ascending ? $0 : $1) < property(ascending ? $1 : $0) }
    }

    static func by(combining descriptors: [Sort.Descriptor<Type>]) -> Sort.Descriptor<Type> {
        return { lhs, rhs in
            for descriptor in descriptors {
                if descriptor(lhs, rhs) { return true }
                if descriptor(rhs, lhs) { return false }
            }
            return false
        }
    }
}
