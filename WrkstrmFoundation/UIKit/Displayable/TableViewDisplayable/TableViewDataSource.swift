//
//  UITableView+Displayable.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/5/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

class PlaceholderTableViewCell: UITableViewCell { }

public class TableViewDataSource<Model: TableViewDisplayable>: NSObject, UITableViewDataSource, Displayable {

    public typealias CellConfig = ((model: Model.Item, cell: UITableViewCell), IndexPath) -> Void

    public let items: [[Model.Item]]

    private var reusableTypes: [[ReusableCell.Type]]

    public var registrar: Registrar?

    public var config: CellConfig?

    public convenience init(model: Model, registrar: Registrar? = nil, config: CellConfig? = nil) {
        self.init(items: model.items, registrar: registrar, config: config)
    }

    init(items: [[Model.Item]], registrar: Registrar? = nil, config: CellConfig? = nil) {
        self.items = items
        self.config = config
        self.registrar = registrar
        self.reusableTypes = items.map { $0.map { $0.tableReusableCell } }
    }

    public func modelFor(indexPath path: IndexPath) -> Model.Item? {
        return item(for: path)
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if numberOfSections > 1 {
            return .localizedStringWithFormat("Item %@", (section + 1).integerString())
        } else {
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(in: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableType = reusableTypes[indexPath.section][indexPath.row]
        if reusableType.reuseIdentifier() == PlaceholderTableViewCell.reuseIdentifier() {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: reusableType.reuseIdentifier())
        }

        let cell: UITableViewCell!
        switch reusableType {
        case let styleableType as StyleableCell.Type:
            if let cachedCell = tableView.dequeueReusableCell(withIdentifier: styleableType.reuseIdentifier()) {
                cell = cachedCell
            } else {
                cell = (styleableType.init(style: styleableType.cellStyle,
                                           reuseIdentifier: styleableType.reuseIdentifier()) as! UITableViewCell)
                //swiftlint:disable:previous force_cast
                cell.prepareForReuse()
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: reusableType.reuseIdentifier(), for: indexPath)
        }

        let currentItem = item(for: indexPath)
        config?((model: currentItem, cell: cell), indexPath)
        (cell as TableReusableCell).prepare?(for: currentItem, path: indexPath)
        return cell
    }
}
