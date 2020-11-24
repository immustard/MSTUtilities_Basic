//
//  Dictionary.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/22.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import Foundation

public extension Dictionary {
    func mst_jsonString() -> String {
        return MSTTools.jsonString(fromDictionary: self as! Dictionary<String, Any>)
    }
}
