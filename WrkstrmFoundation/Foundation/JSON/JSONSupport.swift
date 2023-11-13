//
//  JSONSupport.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/6/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: Any]

public struct AnyEquatable: Any, Equatable { }

public typealias JSONEquatableDictionary = [String: AnyEquatable]
