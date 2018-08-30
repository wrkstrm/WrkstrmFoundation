//
//  JSONCells.swift
//  WrkstrmUtilities
//
//  Created by Cristian Monterroza on 7/8/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

extension JSON {

    public class BasicCell: UITableViewCell, StyleableCell {

        public static var cellStyle: UITableViewCell.CellStyle = .value1

        required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        public override func prepareForReuse() {
            super.prepareForReuse()
            textLabel?.numberOfLines = 0
            detailTextLabel?.numberOfLines = 0
            selectionStyle = .none
        }
    }

    public class IntegerCell: BasicCell {

        public func prepare(for model: Any?, path: IndexPath) {
            guard case let .integer(key, value)? = model as? JSON.Value else { return }
            textLabel?.text = key.titlecased()
            detailTextLabel?.text = NumberFormatter.integer.string(for: value)
        }
    }

    public class DoubleCell: BasicCell {

        public func prepare(for model: Any?, path: IndexPath) {
            guard case let .double(key, value)? = model as? JSON.Value else { return }
            textLabel?.text = key.titlecased()
            detailTextLabel?.text = value.doubleString()
        }
    }

    public class StringCell: BasicCell {

        public func prepare(for model: Any?, path: IndexPath) {
            guard case let .string(key, value)? = model as? JSON.Value else { return }
            textLabel?.text = key.titlecased()
            detailTextLabel?.text = value
        }
    }

    public class DateCell: BasicCell {

        public func prepare(for model: Any?, path: IndexPath) {
            guard case let .date(key, value)? = model as? JSON.Value else { return }
            textLabel?.text = key.titlecased()
            detailTextLabel?.text = value.localizedString()
        }
    }

    public class ArrayCell: BasicCell {

        public func prepare(for model: Any?, path: IndexPath) {
            guard case let .array(key, arrayValue)? = model as? JSON.Value,
                case let .dictionary(jsonArray) = arrayValue else { return }

            textLabel?.text = key.titlecased()
            let formatString: String!
            if jsonArray.count == 1 {
                formatString = NSLocalizedString("%@ Item", comment: "")
            } else {
                formatString = NSLocalizedString("%@ Items", comment: "")
            }
            detailTextLabel?.text = .localizedStringWithFormat(formatString,
                                                               jsonArray.count.integerString())
            accessoryType = .disclosureIndicator
        }
    }

    public class DictionaryCell: BasicCell {

        public func prepare(for model: Any?, path: IndexPath) {
            guard case let .dictionary(key, jsonDictionary)? = model as? JSON.Value,
                case let .any(json) = jsonDictionary else { return }
            textLabel?.text = key.titlecased()

            let formatString: String!
            if json.count == 1 {
                formatString = NSLocalizedString("%@ Detail", comment: "")
            } else {
                formatString = NSLocalizedString("%@ Details", comment: "")
            }
            detailTextLabel?.text = .localizedStringWithFormat(formatString,
                                                               json.count.integerString())
            accessoryType = .disclosureIndicator
        }
    }

    public class AnyCell: BasicCell {

        public func prepare(for model: Any?, path: IndexPath) {
            guard case let .any(value, key)? = model as? JSON.Value else { return }
            textLabel?.text = key.titlecased()
            detailTextLabel?.text = value
        }
    }
}
