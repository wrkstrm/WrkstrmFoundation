//
//  NumberSequenceViewController.swift
//  Example
//
//  Created by Cristian Monterroza on 9/2/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation
import WrkstrmFoundation

class NumberSequenceViewController: CollectionViewController<[String]> {

    override func viewDidLoad() {
        super.viewDidLoad()
        let datasource = (0...1000).map({ String($0) }).collectionDataSource()
        datasource.registrar = Registrar(classes: [StringCell.self], nibs: nil)
        genericDataSource = datasource
    }
}

extension String: CollectionReusableItem {
    public var collectionReusableCell: CollectionReusableCell.Type {
        return StringCell.self
    }
}

class StringCell: UICollectionViewCell {

    func prepare(for model: Any?, path: IndexPath) {
        backgroundColor = Palette.hsluv(for: .red, index: path.row, count: 1000)
    }
}
