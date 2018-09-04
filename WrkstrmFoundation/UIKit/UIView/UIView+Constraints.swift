// UIView+Constraints.swift

import UIKit

extension UIView {

    private struct AssociatedKey {

        static var constraintCache = "wsm_constraintCache"
    }

    typealias ConstraintCache = [NSLayoutConstraint: CGFloat]

    private var constraintCache: ConstraintCache {
        get {
            if let cache = objc_getAssociatedObject(self,
                                                    &AssociatedKey.constraintCache) as? ConstraintCache {
                return cache
            } else {
                let cache = ConstraintCache()
                objc_setAssociatedObject(self,
                                         &AssociatedKey.constraintCache,
                                         cache,
                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return cache
            }
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKey.constraintCache,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func cache(_ constraint: NSLayoutConstraint) {
        constraintCache[constraint] = constraint.constant
    }

    public func reset(_ constraint: NSLayoutConstraint) {
        constraint.constant = constraintCache[constraint, default: 0]
    }

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
