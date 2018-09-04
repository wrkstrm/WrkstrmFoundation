//
//  UIView+Animation.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/3/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

extension CGFloat {

    public static let minAlphaForTouchInput: CGFloat = 0.010000001
}

extension UIView {

    @discardableResult
    public func perform(animation: Animation,
                        completion: ((UIViewAnimatingPosition) -> Void)?) -> UIViewPropertyAnimator {
        let options = animation.options
        let stage = animation.stage

        stage.load?()
        self.layoutIfNeeded()

        let animations = { [weak self] in
            stage.perform?()
            self?.layoutIfNeeded()
        }

        let finalCompletion: (UIViewAnimatingPosition) -> Void = { [weak self] position in
            guard let strongSelf = self else {
                completion?(position)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + options.hold) {
                if let next = animation.next {
                    strongSelf.perform(animation: next, completion: completion)
                } else {
                    completion?(position)
                }
            }
        }

        return UIViewPropertyAnimator.runningPropertyAnimator(withDuration: options.duration,
                                                              delay: options.delay,
                                                              options: options.timingOptions,
                                                              animations: animations,
                                                              completion: finalCompletion)
    }

    public func hide(_ views: [UIView]) {
        views.forEach { $0.alpha = .minAlphaForTouchInput }
    }

    public func show(_ views: [UIView]) {
        views.forEach { $0.alpha = 1 }
    }
}
