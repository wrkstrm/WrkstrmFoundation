//
//  JSONTableViewController.swift
//  WrkstrmUtilities
//
//  Created by Cristian Monterroza on 7/8/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

open class JSONTableViewController: TableViewController<JSON.Displayable> {

    open override func viewDidLoad() {
        super.viewDidLoad()
        assertDependencies()
    }

    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: true) }
        guard let item = genericDataSource?.modelFor(indexPath: indexPath) else { return nil }
        switch item {
        case let .array(_, jsonArray):
            switch jsonArray {
            case let .dictionary(jsonArray):
                return jsonArray.isEmpty ? nil : indexPath
            case .any:
                return nil
            }
        case let .dictionary(_, equatableJsonDictionary):
            switch equatableJsonDictionary {
            case let .any(jsonDictionary):
                return jsonDictionary.isEmpty ? nil : indexPath
            }
        default:
            return nil
        }
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: true) }
        guard let item = genericDataSource?.modelFor(indexPath: indexPath) else { return }

        var jsonTuple: (key: String, jsonArray: [JSONDictionary])?
        switch item {
        case let .dictionary(_, equatableJSONDictionary):
            switch equatableJSONDictionary {
            case let .any(jsonDictionary):
                jsonTuple = (key: "", jsonArray: [jsonDictionary])
            }
        case let .array(key, equatableJsonArray):
            switch equatableJsonArray {
            case let .dictionary(array):
                jsonTuple = (key: key, jsonArray: array)
            default:
                break
            }
        default:
            break
        }

        if let tuple = jsonTuple {
            let controller = JSONTableViewController(style: .plain)
            var jsonDisplayble = JSON.Displayable(jsonArray: tuple.jsonArray)
            jsonDisplayble.dateKeyFuzzyOverride = ["time", "date"]
            controller.title = tuple.key.capitalized
            controller.inject(jsonDisplayble.dataSource())
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
