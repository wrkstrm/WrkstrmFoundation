//
//  TableViewDisplayble.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/2/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public protocol TableViewDisplayable: Indexable where Item: TableReusableItem {

    func reusableCell(for path: IndexPath) -> TableReusableCell.Type

    func title(for section: Int) -> String?

    func dataSource(config: TableViewDataSource<Self>.CellConfig?) -> TableViewDataSource<Self>
}

public extension TableViewDisplayable {

    func reusableCell(for path: IndexPath) -> TableReusableCell.Type {
        return item(for: path).tableReusableCell
    }

    func dataSource(config: TableViewDataSource<Self>.CellConfig? = nil) -> TableViewDataSource<Self> {
        return TableViewDataSource(model: self, config: config)
    }
}

extension Array: TableViewDisplayable where Element: TableReusableItem {

    public func title(for section: Int) -> String? {
        return nil
    }

    // swiftlint:disable:next line_length
    public func tableDataSource(config: TableViewDataSource<[Element]>.CellConfig? = nil) -> TableViewDataSource<[Element]> {
        return TableViewDataSource(items: items, config: config)
    }
}
