//
//  TableViewCell.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/8/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

open class TableViewCell: UITableViewCell {

    var model: Any?

    weak var delegate: UIViewController?
}
