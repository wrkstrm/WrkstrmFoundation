//
//  GenericTableViewController.swift
//  WrkstrmFoundation
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
            if let registrar = genericDataSource?.registrar {
                tableView.addRegistar(registrar)
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
