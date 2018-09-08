//
//  UIView+NibLoading.swift
//  gymkhana
//
//  Created by Cristian Monterroza on 9/3/18.
//  Copyright © 2018 wrkstrm. All rights reserved.
//

import UIKit

extension UIView {

    /// Returns the center of the bounds.
    /// Helpful when trying to center a subview insdide another subview.
    public var boundsCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    public func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
