//
//  MSTTools_String.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/20.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

// MARK: - Convert To Json String
public extension MSTTools {
    class func jsonString(fromString string: String) -> String {
        return "\"\(string.replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: "\"", with: "\\\""))\""
    }
    
    class func jsonString(fromDictionary dictinary: Dictionary<String, Any>) -> String {
        guard !dictinary.isEmpty else { return "" }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dictinary, options: .prettyPrinted)
            
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    class func jsonString(fromArray array: Array<Any>) -> String {
        guard !array.isEmpty else { return "" }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    class func jsonString(from obj: Any?) -> String {
        guard obj != nil else { return "" }
        
        var value = ""
        if obj is String {
            value = jsonString(fromString: obj as! String)
        } else if obj is Dictionary<String, Any> {
            value = jsonString(fromDictionary: obj as! Dictionary<String, Any>)
        } else if obj is Array<Any> {
            value = jsonString(fromArray: obj as! Array<Any>)
        }
        
        return value
    }
}

// MARK: - Convert From Json String
public extension MSTTools {
    class func convertToDictionary(jsonString string: String) -> Dictionary<String, Any> {
        guard !string.isEmpty else { return Dictionary() }
        
        let data = string.data(using: .utf8) ?? Data()
        
        do {
            let dic = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>

            return dic
        } catch {
            return Dictionary()
        }
    }
    
    class func convertToArray(jsonString string: String) -> Array<Any> {
        guard !string.isEmpty else { return Array() }

        let data = string.data(using: .utf8) ?? Data()

        do {
            let arr = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Array<Any>

            return arr
        } catch {
            return Array()
        }
    }
}
