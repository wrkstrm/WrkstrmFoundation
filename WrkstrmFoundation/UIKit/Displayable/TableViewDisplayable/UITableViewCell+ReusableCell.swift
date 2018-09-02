//
//  UITableViewCell+Reusable.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/4/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

@objc
public protocol StyleableCell: TableReusableCell {

    static var cellStyle: UITableViewCell.CellStyle { get }

    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
}

extension UITableViewCell: TableReusableCell {

    @objc
    open class var defaultNib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    @objc
    open class func reuseIdentifier() -> String {
        return String(describing: self) + "Identifier"
    }
}
