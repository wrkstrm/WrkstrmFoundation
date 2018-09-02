//
//  CollectionViewDisplayble.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/2/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public protocol CollectionViewDisplayable: Displayable where Item: CollectionReusableItem {

    func reusableCell(for path: IndexPath) -> CollectionReusableCell.Type

    func dataSource(config: CollectionViewDataSource<Self>.CellConfig?) -> CollectionViewDataSource<Self>

    func supplementaryElementView(for collectionView: UICollectionView,
                                  of kind: String,
                                  at indexPath: IndexPath) -> UICollectionReusableView?

}

public extension CollectionViewDisplayable {

    public func reusableCell(for path: IndexPath) -> CollectionReusableCell.Type {
        return item(for: path).collectionReusableCell
    }

    public func dataSource(config: CollectionViewDataSource<Self>.CellConfig? = nil) -> CollectionViewDataSource<Self> {
        return CollectionViewDataSource(model: self, config: config)
    }

    public func supplementaryElementView(for collectionView: UICollectionView,
                                         of kind: String,
                                         at indexPath: IndexPath) -> UICollectionReusableView? {
        return nil
    }
}

extension Array: CollectionViewDisplayable where Element: CollectionReusableItem {

    // swiftlint:disable:next line_length
    public func dataSource(config: CollectionViewDataSource<[Element]>.CellConfig? = nil) -> CollectionViewDataSource<[Element]> {
        return CollectionViewDataSource(model: self, config: config)
    }
}
