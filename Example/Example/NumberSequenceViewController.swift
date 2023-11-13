//
//  NumberSequenceViewController.swift
//  Example
//
//  Created by Cristian Monterroza on 9/2/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation
import WrkstrmFoundation

extension NumberSequenceViewController: Injectable {

    func inject(_ resource: UIFont) {
        font = resource
    }

    func assertDependencies() {
        assert(font != nil)
    }
}

class NumberSequenceViewController: CollectionViewController<[String]> {

    var font: UIFont!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.assertDependencies()
        let datasource = (1000...2000).map({ $0.integerString() }).collectionDataSource { cell, _, _ in
            guard let cell = cell as? StringCell else { return }
            cell.label.font = self.font
        }
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
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

    func prepare(for model: Any?, path: IndexPath) {
        guard let string = model as? String else { return }

        let gradient = Palette.Gradient(rawValue: (path.row % 5))
        backgroundColor = Palette.hsluv(for: gradient!, index: path.row, count: 1000)
        if label.superview == nil {
            contentView.addSubview(label)
            label.constrainEdges(to: contentView)
            label.textAlignment = .center
        }
        label.text = string
    }
}
