//
//  UICollectionView+ReusableCell.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/2/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public extension UICollectionView {

    func register(nib cells: [UICollectionReusableView.Type]) {
        cells.forEach {
            self.register($0.defaultNib, forCellWithReuseIdentifier: $0.reuseIdentifier())
        }
    }

    func register(classes cells: [UICollectionReusableView.Type]) {
        cells.forEach {
            self.register($0, forCellWithReuseIdentifier: $0.reuseIdentifier())
        }
    }

    func dequeueReusableCell<Cell: ReusableCell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier(), for: indexPath) as! Cell
    }
}
