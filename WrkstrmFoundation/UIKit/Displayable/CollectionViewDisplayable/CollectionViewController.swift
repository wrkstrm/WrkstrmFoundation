//
//  CollectionViewController.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/2/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

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
            if let registrar = genericDataSource?.registrar {
                collectionView.addRegistar(registrar)
            }
            collectionView.dataSource = genericDataSource
            collectionView.reloadData()
        }
    }
}
