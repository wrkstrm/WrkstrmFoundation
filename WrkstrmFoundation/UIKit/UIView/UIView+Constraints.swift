// UIView+Constraints.swift

import UIKit

extension UIView {

    public func constrainEqual(attribute: NSLayoutConstraint.Attribute,
                               to: AnyObject,
                               multiplier: CGFloat = 1,
                               constant: CGFloat = 0) {
        constrainEqual(attribute: attribute,
                       to: to, attribute,
                       multiplier: multiplier,
                       constant: constant)
    }

    public func constrainEqual(attribute: NSLayoutConstraint.Attribute,
                               to: AnyObject,
                               _ toAttribute: NSLayoutConstraint.Attribute,
                               multiplier: CGFloat = 1,
                               constant: CGFloat = 0) {
        NSLayoutConstraint.activate([NSLayoutConstraint(item: self,
                                                        attribute: attribute,
                                                        relatedBy: .equal,
                                                        toItem: to,
                                                        attribute: toAttribute,
                                                        multiplier: multiplier,
                                                        constant: constant)])
    }

    public func constrainEdges(to view: UIView) {
        constrainEqual(attribute: .top, to: view, .top)
        constrainEqual(attribute: .leading, to: view, .leading)
        constrainEqual(attribute: .trailing, to: view, .trailing)
        constrainEqual(attribute: .bottom, to: view, .bottom)
    }

    /// If the `view` is nil, we take the superview.
    public func constrainToCenter(in view: UIView? = nil) {
        guard let container = view ?? self.superview else { fatalError() }
        centerXAnchor.constrainEqual(anchor: container.centerXAnchor)
        centerYAnchor.constrainEqual(anchor: container.centerYAnchor)
    }
}

extension NSLayoutAnchor {
    @objc public func constrainEqual(anchor: NSLayoutAnchor, constant: CGFloat = 0) {
        constraint(equalTo: anchor, constant: constant).isActive = true
    }
}
