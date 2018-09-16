//
//  Displayable.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/5/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public protocol Displayable {

    associatedtype Item: Equatable

    var items: [[Item]] { get }

    func item(for path: IndexPath) -> Item

    func indexPath(for item: Item) -> IndexPath?
}

extension Displayable {

    var numberOfSections: Int {
        return items.count
    }

    func numberOfItems(in section: Int) -> Int {
        return items[section].count
    }

    public func item(for path: IndexPath) -> Item {
        return items[path.section][path.row]
    }

    public func indexPath(for item: Item) -> IndexPath? {
        for (index, section) in items.enumerated() {
            if let row = section.index(of: item) {
                return IndexPath(row: row, section: index)
            }
        }
        return nil
    }
}

extension Array: Displayable where Element: Equatable {

    public typealias Item = Element

    public var items: [[Element]] {
        return [self]
    }
}
