//
//  Array.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/22.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import Foundation

public extension Array {
    func mst_jsonString() -> String {
        return MSTTools.jsonString(fromArray: self)
    }
}

public extension Array where Element: Equatable {
    mutating func mst_remove(_ object: Element) {
        if let idx = firstIndex(of: object) {
            remove(at: idx)
        }
    }
}
