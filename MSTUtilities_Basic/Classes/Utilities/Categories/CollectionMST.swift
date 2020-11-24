//
//  CollectionMST.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/6/15.
//

import Foundation

public extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
