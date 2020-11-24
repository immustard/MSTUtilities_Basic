//
//  CheckUpdateTool.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/3/14.
//

import UIKit

public enum kApplicationUpdateType {
    case none   // 不需要升级
    
    case normal // 正常升级
    
    case forced // 强制升级
}

public class CheckUpdateTool {
    
    /// 检查版本升级
    public class func checkUpdate(appID: String, appStoreAddress: String, closure: @escaping ((kApplicationUpdateType, String) -> Void)) {
        guard !kStrIsEmpty(appID) else {
            closure(.none, "")
            return
        }
        
        let urlStr = "https://itunes.apple.com/cn/lookup?id=" + appID
        
        MSTHTTPManager.request(urlStr, method: .get, params: [:], headers: nil) { (response, err) in
            if err.code == .success {
                
            } else {
                closure(.none, "")
            }
        }
        
//        let session = URLSession.shared
//
//        let task = session.dataTask(with: url) { (data, response, error) in
//            guard error != nil else {
//                MSTTools.doTaskAsynInMain {
//                }
//                return
//            }
//
//            let str = String(data: data ?? Data(), encoding: .utf8) ?? ""
//
//            let result = MSTTools.convertToDictionary(jsonString: str)
//
//            let array = result["results"] as! [[String: Any]]
//
//            if let dic = array.first {
//                let address = dic["trackViewUrl"] as? String ?? appStoreAddress
//
//                let version = dic["version"] as? String ?? "1.0.0"
//                let cVersion = MSTTools.shared.appVersion ?? "1.0.0"
//
//                let vArr = version.components(separatedBy: ".")
//                let cArr = cVersion.components(separatedBy: ".")
//
//                if cArr.first!.mst_intValue > vArr.first!.mst_intValue {
//                    // 当前版本比商店版本高
//                    closure(.none, "")
//                    return
//                }
//
//                if vArr.first!.mst_intValue > cArr.first!.mst_intValue {
//                    // 强制升级
//                    closure(.forced, address)
//                    return
//                }
//
//                if cArr[1].mst_intValue > vArr[1].mst_intValue {
//                    // 当前版本比商店版本高
//                    closure(.none, "")
//                    return
//                }
//
//                if vArr[1].mst_intValue > cArr[1].mst_intValue {
//                    // 强制升级
//                    closure(.forced, address)
//                    return
//                }
//
//                if vArr.last!.mst_intValue > cArr.last!.mst_intValue {
//                    // 普通升级
//                    closure(.normal, address)
//                    return
//                }
//
//                MSTTools.doTaskAsynInMain {
//                    closure(.none, address)
//                }
//            } else {
//                MSTTools.doTaskAsynInMain {
//                    closure(.none, "")
//                }
//            }
//        }
//
//        task.resume()
    }
    
}
