//
//  Collection+Utilities.swift
//  WrkstrmUtilities
//
//  Created by Cristian Monterroza on 8/16/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public extension Collection where Element: Comparable, Index == Int {
    public func search(key: Element) -> Int? {
        var lower = self.startIndex
        var upper = self.endIndex

        while lower < upper {
            let mid = index(lower, offsetBy: (upper - lower) / 2)
            if self[mid] == key {
                return mid
            } else if self[mid] < key {
                lower = mid + 1
            } else {
                upper = mid
            }
        }
        return nil
    }
}

public extension Collection where Element: Comparable, Index == Int {
    func mergeSort() -> [Element] {
        guard self.count > 1 else { return Array(self) }

        let midIndex = startIndex + (endIndex - startIndex) / 2
        let left = self[startIndex..<midIndex].mergeSort()
        let right = self[midIndex..<endIndex].mergeSort()

        return merge(left: left, right: right)
    }

    private func merge<T: Comparable>(left: [T], right: [T]) -> [T] {
        var mergedArray = ArraySlice<T>()

        var left = ArraySlice(left)
        var right = ArraySlice(right)

        while !left.isEmpty && !right.isEmpty {
            if left.first! < right.first! {
                mergedArray.append(left.removeFirst())
            } else {
                mergedArray.append(right.removeFirst())
            }
        }
        return Array(mergedArray + left + right)
    }
}
