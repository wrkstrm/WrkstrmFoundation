//
//  UITableView+Reusable.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/5/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

public extension UITableView {

    func register(nib cells: [UITableViewCell.Type]) {
        cells.forEach {
            self.register($0.defaultNib, forCellReuseIdentifier: $0.reuseIdentifier())
        }
    }

    func register(classes cells: [UITableViewCell.Type]) {
        for cell in cells where !(cell is StyleableCell.Type) {
            register(cell.self, forCellReuseIdentifier: cell.reuseIdentifier())
        }
    }

    func dequeueReusableCell<Cell: ReusableCell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier(), for: indexPath) as! Cell
    }
}
