//
//  ReusableItem.swift
//  WrkstrmUtilities
//
//  Created by Cristian Monterroza on 7/5/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public protocol ReusableItem: Equatable {

    var reusableCell: UITableViewCell.Type { get }
}
