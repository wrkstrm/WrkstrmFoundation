//
//  TypographyController.swift
//  gymkhana
//
//  Created by Cristian Monterroza on 8/30/18.
//  Copyright © 2018 wrkstrm. All rights reserved.
//

import UIKit
import WrkstrmFoundation

// Global Notification transformers allow for consistent notifications across the app.
let fontChanges = NotificationTransformer<Void>(name: UIContentSizeCategory.didChangeNotification)

// Although this is a Typography Controller, the TableViewController will accept any [String] as it's datasource.
class TypographyController: TableViewController<[String]> {

    // Notification Tokens automatically remove themselves as observers on controller deinit.
    var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("iOS Fonts", comment: "")

        tableView.separatorStyle = .none

        // Block based notification listening for convenience
        token = NotificationCenter.default.addObserver(for: fontChanges) { _ in
            self.tableView.reloadData()
        }

        // Data sources can be created by simply passing along any  array of Strings.
        let dataSource = UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }.tableDataSource()

        // A datasource can register classes and nibs to the tableview automatically.

        dataSource.registrar = Registrar(classes: [FontCell.self], nibs: nil)

        // Setting the data source reloads the table view.
        genericDataSource = dataSource
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: true) }
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .horizontal
        let detail = NumberSequenceViewController(collectionViewLayout: layout)
        splitViewController?.showDetailViewController(detail, sender: nil)
    }
}

// A "ReusableItem" identities what type of cell it re-uses during the dequeue-ing process.
extension String: TableReusableItem {

    public var tableReusableCell: TableReusableCell.Type {
        return FontCell.self
    }
}

// The TableViewCell has a reference to the controller for delegating purposes.
// A StyleableCell can chose between the default UITableViewStyles when being dequeued.
class FontCell: TableViewCell, StyleableCell {

    static var cellStyle: UITableViewCell.CellStyle = .subtitle

    // This required initializer is needed for the `StyleableCell` protocol.
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // All UITableViewCells with WrkstrmFoundation can implement this method
    // to have the data automatically passed to them by a TableViewDataSource
    func prepare(for model: Any?, path: IndexPath) {
        guard let fontName = model as? String else { return }
        textLabel?.text = fontName
        let system =  UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        let cell = UIFont(name: fontName, size: system.pointSize)
        textLabel?.font = UIFontMetrics.default.scaledFont(for: cell!)
    }
}
