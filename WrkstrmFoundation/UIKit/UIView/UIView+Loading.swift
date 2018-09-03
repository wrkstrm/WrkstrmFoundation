//
//  UIView+NibLoading.swift
//  gymkhana
//
//  Created by Cristian Monterroza on 9/3/18.
//  Copyright © 2018 wrkstrm. All rights reserved.
//

import UIKit

extension UIView {

}
extension UIView {

    private struct AssociatedKey {

        static var embeddedView = "wsm_embeddedView"
    }

    @IBOutlet var embeddedView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.embeddedView) as? UIView
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKey.embeddedView,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: View Loading

    class func forDefaultNib<View: UIView>(_ viewClass: View.Type) -> View {
        let nibName = String(describing: viewClass)
        let nibObjects = Bundle(for: viewClass).loadNibNamed(nibName, owner: self, options: nil)
        if let view = nibObjects?.first as? View {
            return view
        } else {
            fatalError("Nib loading failed for view: " + String(describing: viewClass))
        }
    }

    /// Returns the center of the bounds.
    /// Helpful when trying to center a subview insdide another subview.
    var boundsCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    /// Override this method to specify a nib that is not named similarly to the class name.
    /// This is required for Nested view types in Swift.
    //// Names like Nested.View are translated to simply "View"
    var defaultNib: UINib? {
        return nil
    }

    /// Calls this method in a commonInit after both init with frame and coder to add the embedded view.
    func loadEmbeddedView() {
        let nib = defaultNib ?? UINib(nibName: String(describing: type(of: self)),
                                      bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        if let newView = embeddedView {
            newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(newView)
            newView.frame = bounds
            newView.center = boundsCenter
            layoutIfNeeded()
        }
    }

    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
