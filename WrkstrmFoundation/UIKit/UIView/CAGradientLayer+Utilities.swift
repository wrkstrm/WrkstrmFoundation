//
//  UIView+Gradients.swift
//  wrkstrm
//
//  Created by Cristian Monterroza on 9/11/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import QuartzCore

extension CAGradientLayer {

    typealias Positions = (start: CGPoint, end: CGPoint)

    enum Direction: CaseIterable {

        case leftRight

        case rightLeft

        case topBottom

        case bottomTop

        case topLeftBottomRight

        case bottomRightTopLeft

        case topRightBottomLeft

        case bottomLeftTopRight

        var position: Positions {
            switch self {
            case .leftRight:
                return (start: .init(x: 0, y: 0.5), end: .init(x: 1, y: 0.5))

            case .rightLeft:
                return (start: .init(x: 1, y: 0.5), end: .init(x: 0, y: 0.5))

            case .topBottom:
                return (start: .init(x: 0.5, y: 0), end: .init(x: 0.5, y: 1))

            case .bottomTop:
                return (start: .init(x: 0.5, y: 1), end: .init(x: 0.5, y: 0))

            case .topLeftBottomRight:
                return (start: .init(x: 0, y: 0), end: .init(x: 1, y: 1))

            case .bottomRightTopLeft:
                return (start: .init(x: 1, y: 1), end: .init(x: 0, y: 0))

            case .topRightBottomLeft:
                return (start: .init(x: 1, y: 0), end: .init(x: 0, y: 1))

            case .bottomLeftTopRight:
                return (start: .init(x: 0, y: 1), end: .init(x: 1, y: 0))
            }
        }
    }

    var direction: Direction? {
        get {
            return Direction.allCases.first { $0.position == (start: startPoint, end: endPoint) }
        }
        set {
            startPoint = newValue?.position.start ?? CGPoint(x: 0.5, y: 0)
            endPoint = newValue?.position.end ?? CGPoint(x: 0.5, y: 1)
        }
    }
}
