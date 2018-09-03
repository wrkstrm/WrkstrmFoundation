//
//  UITableView+Registrar.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/3/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

public extension UITableView {

    func addRegistar(_ registrar: Registrar) {
        if let classes = registrar.classes as? [UITableViewCell.Type] {
            register(classes: classes)
        }
        if let nibs = registrar.nibs as? [UITableViewCell.Type] {
            register(nib: nibs)
        }
    }
}
