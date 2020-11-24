//
//  MSTTools_Array.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/6/23.
//

import UIKit

public extension MSTTools {
    
    class func convertToArray(_ obj: Any) -> Array<Any> {
        if obj is Array<Any> {
            return obj as! Array<Any>
        } else {
            return [obj]
        }
    }
    
}
