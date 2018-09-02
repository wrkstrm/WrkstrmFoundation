//
//  TreeClass.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 8/16/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public class Tree<T> {

    /// The value contained in this node
    public let value: T

    public var children = [Tree]()

    public weak var parent: Tree?

    public func add(_ child: Tree) {
        children.append(child)
        child.parent = self
    }

    public init(_ value: T) {
        self.value = value
    }
}
