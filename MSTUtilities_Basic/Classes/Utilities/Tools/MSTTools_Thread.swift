//
//  MSTTools_Thread.swift
//  Reader
//
//  Created by 张宇豪 on 2019/7/24.
//  Copyright © 2019 Mustard. All rights reserved.
//

import Foundation

public extension MSTTools {
    
    class func doTaskAsynInMain(_ closure: @escaping (() -> Void)) {
        DispatchQueue.main.async(execute: closure)
    }
    
    class func doTaskSynInMain(_ closure: @escaping (() -> Void)) {
        DispatchQueue.main.sync(execute: closure)
    }
    
    class func doTaskAsyncInGlobal(_ closure: @escaping (() -> Void)) {
        DispatchQueue.global().async(execute: closure)
    }
    
    class func doTaskSyncInGlobal(_ closure: @escaping (() -> Void)) {
        DispatchQueue.global().sync(execute: closure)
    }
    
    class func doTask(deadline: Double, _ closure: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(floatLiteral: deadline), execute: closure)
    }
    
    class func doTaskOnce(token: String = "\(#file):\(#function):\(#line)", _ closure: (() -> Void)) {
        DispatchQueue.once(token: token, closure: closure)
    }
}

public extension DispatchQueue {
    private static var _onceToken = [String]()
    
    class func once(token: String = "\(#file):\(#function):\(#line)", closure: ()->Void) {
        objc_sync_enter(self)
        
        defer {
            objc_sync_exit(self)
        }

        if _onceToken.contains(token) {
            return
        }

        _onceToken.append(token)
        closure()
    }
}


extension DispatchTime: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = DispatchTime.now() + .seconds(value)
    }
}
extension DispatchTime: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = DispatchTime.now() + .milliseconds(Int(value * 1000))
    }
}
