//
//  MSTHTTPManager.swift
//  MustardBase
//
//  Created by Mustard on 2020/11/5.
//  Copyright © 2020 mustard. All rights reserved.
//

import UIKit
import Alamofire

public class MSTHTTPManager {

    static public func request(_ url: String, method: HTTPMethod = .post, params: [String: Any], headers: HTTPHeaders? = nil, completion closure: ((Any?, MSTError) -> Void)?) {
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                MSTTools.doTaskAsynInMain {
                    closure?(value, MSTError(code: .success))
                }
            case .failure(let error):
                var e = MSTError(code: .errNet)
                e.customDescription = error.localizedDescription
                MSTTools.doTaskAsynInMain {
                    closure?(nil, e)
                }
            }
        }
    }

}
