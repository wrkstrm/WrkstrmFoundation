//
//  UICollectionView+Registrar.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/3/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public extension UICollectionView {

    func addRegistar(_ registrar: Registrar) {
        if let classes = registrar.classes as? [UICollectionReusableView.Type] {
            register(classes: classes)
        }
        if let nibs = registrar.nibs as? [UICollectionReusableView.Type] {
            register(nib: nibs)
        }
    }
}
