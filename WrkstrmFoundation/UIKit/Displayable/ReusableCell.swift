//
//  Reusable.swift
//  wrkstrm
//
//  Created by Cristian Monterroza on 7/4/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

@objc
public protocol ReusableCell {

    static var defaultNib: UINib { get }

    static func reuseIdentifier() -> String

    @objc optional func prepare(for model: Any?, path: IndexPath)
}

@objc
public protocol TableReusableCell: ReusableCell { }

@objc
public protocol CollectionReusableCell: ReusableCell { }
