//
//  UICollectionViewCell+ReusableCell.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 8/30/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

extension UICollectionReusableView: ReusableCell {

    public static var defaultNib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    public static func reuseIdentifier() -> String {
        return String(describing: self) + "Identifier"
    }
}
