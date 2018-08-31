// ColorPalette.swift

import Foundation
import UIKit
import HSLuv

public enum Palette {

    public enum Gradient: Int {
        case red = 0
        case green
        case blue
        case black
        case white
        case yellow
    }

    public enum Wrkstrm: Int {
        case physical
        case work
        case social
        case deadTime
        case recovery
    }
}

extension Palette {

    public static func hsluv(for gradient: Gradient, index: Int, count: Int, reversed: Bool = false) -> UIColor {
        var newIndex = Double(index)
        let newCount = Double(count)

        if reversed {
            newIndex = newCount - newIndex
        }
        switch gradient {
        case .red:
            return UIColor(hsluv: HSLuv(h: 12.2,
                                        s: 100.0 - 33.0 * newIndex / newCount,
                                        l: 30.0 + 30.0 * newIndex / newCount), alpha: 1)
        case .blue:
            return UIColor(hsluv: HSLuv(h: 258.6,
                                        s: 100.0 - 33.0 * newIndex / newCount,
                                        l: 30.0 + 30.0 * newIndex / newCount), alpha: 1)

        case .green:
            return UIColor(hsluv: HSLuv(h: 127.7,
                                        s: 100.0 - 33.0 * newIndex / newCount,
                                        l: 50.0 + 25.0 * newIndex / newCount), alpha: 1)
        case .yellow:
            return UIColor(hpluv: HPLuv(h: 86,
                                        s: 100.0 - 33.0 * newIndex / newCount,
                                        l: 70 + 30.0 * newIndex / newCount), alpha: 1)

        case .black:
            return UIColor(hsluv: HSLuv(h: 0,
                                        s: 0,
                                        l: 0 + 40.0 * newIndex / newCount), alpha: 1)

        case .white:
            return UIColor(hsluv: HSLuv(h: 0,
                                        s: 0,
                                        l: 60.0 + 40.0 * newIndex / newCount), alpha: 1)
        }
    }

    public static func color(for wrkstrm: Wrkstrm, index: Int, count: Int, reversed: Bool = false) -> UIColor {
        return color(for: Gradient(rawValue: wrkstrm.rawValue)!,
                     index: index,
                     count: count,
                     reversed: reversed)
    }

    //swiftlint:disable:next function_body_length
    public static func color(for gradient: Gradient, index: Int, count: Int, reversed: Bool = false) -> UIColor {
        var newIndex = CGFloat(index)
        var newCount = CGFloat(count)

        if reversed {
            newIndex = newCount - newIndex
        }

        var starting: (red: CGFloat, green: CGFloat, blue: CGFloat)!
        var ending: (red: CGFloat, green: CGFloat, blue: CGFloat)!

        var cutoff: CGFloat = 0
        switch gradient {
        case .green:
            starting = (red: 25, green: 190, blue: 25)
            let (sR, sG, sB) = starting
            cutoff = 5
            ending = (red: sR + cutoff * 10,
                      green: sG + cutoff * 10,
                      blue: sB + cutoff * 10)
        case .blue:
            starting = (red: 45, green: 100, blue: 215)
            let (sR, sG, sB) = starting
            cutoff = 6
            ending = (red: sR + cutoff * 12,
                      green: sG + cutoff * 12,
                      blue: sB + cutoff * 10)
        case .red:
            starting = (red: 215, green: 25, blue: 25)
            let (sR, sG, sB) = starting
            cutoff = 4
            ending = (red: sR + cutoff * 10,
                      green: sG + cutoff * 20,
                      blue: sB + cutoff * 10)
        case .black:
            starting = (red: 65, green: 65, blue: 65)
            let (sR, sG, sB) = starting
            cutoff = 7
            ending = (red: sR + cutoff * 8,
                      green: sG + cutoff * 8,
                      blue: sB + cutoff * 8)
        default:
            starting = (red: 200, green: 200, blue: 200)
            let (sR, sG, sB) = starting
            cutoff = 6
            ending = (red: sR + cutoff * 6,
                      green: sG + cutoff * 6,
                      blue: sB + cutoff * 6)
        }

        var delta = 1.0 / cutoff
        if newCount > cutoff {
            delta = 1.0 / newCount

        } else {
            newCount = cutoff
        }

        assert(newIndex <= newCount)

        let s = delta * (newCount - newIndex)
        let e = delta * newIndex

        let (sR, sG, sB) = starting
        let (eR, eG, eB) = ending

        let red = sR * s + eR * e
        let green = sG * s + eG * e
        let blue = sB * s + eB * e
        let color = UIColor(red: red / 255.0,
                            green: green / 255.0,
                            blue: blue / 255.0,
                            alpha: 1.0)
        return color
    }
}
