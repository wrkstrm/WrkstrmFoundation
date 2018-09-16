//
//  ReusableItem.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/5/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public protocol TableReusableItem: Equatable {

    var tableReusableCell: TableReusableCell.Type { get }
}

public protocol CollectionReusableItem: Equatable {

    var collectionReusableCell: CollectionReusableCell.Type { get }
}
