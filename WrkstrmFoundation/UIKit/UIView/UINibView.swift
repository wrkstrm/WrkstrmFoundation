//
//  UINibView.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/8/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit

class UINibView: UIView {

    @IBOutlet open var embeddedView: UIView?

    // MARK: View Loading
    /// Override this method to specify a nib that is not named similarly to the class name.
    /// This is required for Nested view types in Swift.
    //// Names like Nested.View are translated to simply "View"
    open var defaultNib: UINib? {
        return nil
    }

    /// Calls this method in a commonInit after both init with frame and coder to add the embedded view.
    open func loadEmbeddedView() {
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
}
