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

    func perform(animation: Animation, completion: ((UIViewAnimatingPosition) -> Void)?) {
        guard case let .animation(options, stage, next) = animation else { return }

        stage.load?()
        self.layoutIfNeeded()

        let animations = {
            stage.perform?()
            self.layoutIfNeeded()
        }

        let finalCompletion: (UIViewAnimatingPosition) -> Void = { position in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + options.hold) {
                if let next = next {
                    self.perform(animation: next, completion: completion)
                } else {
                    completion?(position)
                }
            }
        }

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: options.duration,
                                                       delay: options.delay,
                                                       options: options.timingOptions,
                                                       animations: animations,
                                                       completion: finalCompletion)
    }

    func hide(_ views: [UIView]) {
        views.forEach { $0.alpha = .minAlphaForTouchInput }
    }

    func show(_ views: [UIView]) {
        views.forEach { $0.alpha = 1 }
    }
}
