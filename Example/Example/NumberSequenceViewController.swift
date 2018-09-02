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
        genericDataSource = (0...10).map({ String($0) }).collectionDataSource()
    }
}

extension String: CollectionReusableItem {
    public var collectionReusableCell: CollectionReusableCell.Type {
        return StringCell.self
    }
}

class StringCell: UICollectionViewCell {

    func prepare(for model: Any?, path: IndexPath) {
        print("this get's called")
    }
}
