//
//  CollectionViewController.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/2/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

extension CollectionViewController: Injectable {

    public func inject(_ resource: CollectionViewDataSource<Model>) {
        genericDataSource = resource
    }

    public func assertDependencies() {
        assert(genericDataSource != nil)
    }
}

open class CollectionViewController<Model: CollectionViewDisplayable>: UICollectionViewController {

    open var displayableModel: Model? {
        didSet {
            if let displayableModel = displayableModel {
                genericDataSource = displayableModel.dataSource()
            }
        }
    }

    open var genericDataSource: CollectionViewDataSource<Model>? {
        didSet {
            if let classes = genericDataSource?.registrar?.classes as? [UICollectionReusableView.Type] {
                collectionView.register(classes: classes)
            }
            if let nibs = genericDataSource?.registrar?.nibs as? [UICollectionReusableView.Type] {
                collectionView.register(nib: nibs)
            }
            collectionView.dataSource = genericDataSource
            collectionView.reloadData()
        }
    }
}
