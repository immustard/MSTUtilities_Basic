//
//  MSTKeyValueModel.swift
//  MSTUtilities_Basic
//
//  Created by Mustard on 2020/11/24.
//

import UIKit
import HandyJSON

public class MSTKeyValueModel: HandyJSON {

    public var key: String = ""
    
    public var value: String = ""
    
    public var superKey: String = ""
    
    public var type: String?
    
    public var standby_1: String?
    
    public var standby_2: String?
    
    public var subItems: [MSTKeyValueModel] = []
    
    required public init() {}
    
    public convenience init(key: String, value: String) {
        self.init()
        
        self.key = key
        self.value = value
    }
    
}
