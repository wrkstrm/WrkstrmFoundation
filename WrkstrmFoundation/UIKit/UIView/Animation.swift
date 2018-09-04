//
//  Animation.swift
//  gymkhana
//
//  Created by Cristian Monterroza on 9/3/18.
//  Copyright © 2018 wrkstrm. All rights reserved.
//

import UIKit

public indirect enum Animation {

    case animation(Options, Stage, Animation?)

    public struct Options: Equatable {

        public let duration: TimeInterval

        public let delay: TimeInterval

        public let timingOptions: UIView.AnimationOptions

        public let hold: TimeInterval

        public init(duration: TimeInterval,
                    delay: TimeInterval = 0,
                    timingOptions: UIView.AnimationOptions = [],
                    hold: TimeInterval = 0) {
            self.duration = duration
            self.delay = delay
            self.timingOptions = timingOptions
            self.hold = hold
        }

        public static func options(duration: TimeInterval,
                                   delay: TimeInterval = 0,
                                   timingOptions: UIView.AnimationOptions = [],
                                   hold: TimeInterval = 0) -> Options {
            return self.init(duration: duration,
                             delay: delay,
                             timingOptions: timingOptions,
                             hold: hold)
        }
    }

    public struct Stage {

        public var load: (() -> Void)?

        public let perform: (() -> Void)?

        public init(load: (() -> Void)? = nil, perform: (() -> Void)?) {
            self.load = load
            self.perform = perform
        }

        public static func stage(load: (() -> Void)? = nil, perform: (() -> Void)?) -> Stage {
            return self.init(load: load, perform: perform)
        }
    }
}

public extension Animation {

    public init(options: Options, stage: Stage, next: Animation?) {
        self = .animation(options, stage, next)
    }

    public init(options: Options, stage: Stage) {
        self = .animation(options, stage, nil)
    }
}

extension Animation: Sequence {
    
    public func makeIterator() -> AnimationIterator {
        return AnimationIterator(animation: self)
    }
}

public struct AnimationIterator: IteratorProtocol {

    var animation: Animation?

    public mutating func next() -> Animation? {
        switch animation {
        case let .animation(_, _, next)?:
            animation = next
            return next
        case .none:
            return nil
        }
    }
}
