//
//  MSTError.swift
//  MustardBase
//
//  Created by Mustard on 2020/11/5.
//  Copyright © 2020 mustard. All rights reserved.
//

import Foundation

enum MSTErrorCode: Int {
    case success            = 0     // 成功
    case timeout            = -1    // 超时
    case errBody            = -2    // 消息体错误
    case errNet             = -3    // 网络错误
    case upload             = -4    // 上传文件失败
    case download           = -5    // 下载文件失败
    case errServiceMsg      = -6    // 服务器返回错误
    case nilResponse        = -7    // 服务器返回为空
    case nilURL             = -8    // 地址为空
    case analysisFailure    = -9    // 消息体解析失败
    case locationFailure    = -10   // 定位失败
    case autoLoginFailure   = -11   // 自动登录失败
    case unkown             = -99   // 未知错误
    
}

public struct MSTError: Error {
    var code: MSTErrorCode
    
    var customDescription: String = ""
}

extension MSTError: CustomStringConvertible {
    public var description: String {
        if kStrIsEmpty(customDescription) {
            switch code {
            case .success:
                return "成功"
            case .timeout:
                return "请求超时, 请稍候重试"
            case .errBody:
                return "请求错误"
            case .errNet:
                return "当前网络错误"
            case .locationFailure:
                return "定位失败"
            case .nilResponse:
                return "服务器返回为空"
            case .nilURL:
                return "访问地址为空"
            case .errServiceMsg:
                return "服务器返回错误"
            case .analysisFailure:
                return "消息体解析失败"
            case .autoLoginFailure:
                return "自动登录失败, 请重新登录"
            case .upload:
                return "上传文件失败"
            case .download:
                return "下载文件失败"
            case .unkown:
                return "未知错误"
            }
        } else {
            return customDescription
        }
    }
}
