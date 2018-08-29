//
//  GenericTableViewController.swift
//  WrkstrmUtilities
//
//  Created by Cristian Monterroza on 7/6/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

open class TableViewController<Model: TableViewDisplayable>: UITableViewController {

    open var displayableModel: Model? {
        didSet {
            if let displayableModel = displayableModel {
                genericDataSource = displayableModel.dataSource()
            }
        }
    }

    open var genericDataSource: TableViewDataSource<Model>? {
        didSet {
            if let classes = genericDataSource?.registrar?.classes as? [UITableViewCell.Type] {
                tableView.register(classes: classes)
            }
            if let nibs = genericDataSource?.registrar?.nibs as? [UITableViewCell.Type] {
                tableView.register(nib: nibs)
            }
            tableView.dataSource = genericDataSource
            tableView.reloadData()
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }
}

extension TableViewController: Injectable {

    public func inject(_ resource: TableViewDataSource<Model>) {
        genericDataSource = resource
    }

    public func assertDependencies() {
        assert(genericDataSource != nil)
    }
}
