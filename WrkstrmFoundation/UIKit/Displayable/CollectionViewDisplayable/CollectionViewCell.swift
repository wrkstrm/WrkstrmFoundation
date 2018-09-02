//
//  CollectionViewCell.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/2/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

open class CollectionViewCell: UITableViewCell {

    var model: Any?

    weak var delegate: UIViewController?
}
