//
//  Grid.swift
//  gymkhana
//
//  Created by Cristian Monterroza on 8/30/18.
//  Copyright © 2018 wrkstrm. All rights reserved.
//

import UIKit

public struct Grid {
    public let rows: Int
    public let columns: Int

    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
    }

    func itemSize(for frame: CGSize) -> CGSize {
        return CGSize(width: frame.width / CGFloat(rows),
                      height: frame.height / CGFloat(columns))
    }
}
