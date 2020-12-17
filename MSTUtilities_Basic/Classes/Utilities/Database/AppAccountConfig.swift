//
//  AppConfig.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2019/12/31.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import Foundation

private let IsAuto =        "AppConfig_IsAutoLogin"     // 是否自动登录
private let LoginAccount =  "AppConfig_LoginAccount"    // 用户账号
private let LoginPassword = "AppConfig_LoginPassword"   // 用户密码
private let LoginUserID =   "AppConfig_LoginUserID"     // 用户ID
private let LoginKey =      "AppConfig_LoginKey"        // 登录key
private let DeviceToken =   "AppConfig_DeviceToken"     // token

public class AppAccountConfig: NSObject {
    /// 单例
    public class var shared: AppAccountConfig {
        struct Static {
            static let kConfig = AppAccountConfig()
        }
        
        return Static.kConfig
    }
    
    let ud = UserDefaults.standard
    
    public var isFromLogin: Bool = false
}

// MARK: - 账号
public extension AppAccountConfig {
    /// 设置是否自动登录
    func setIsAutoLogin(_ isAuto: Bool) {
        ud.set(isAuto, forKey: IsAuto)
        ud.synchronize()
    }
    
    /// 获取是否自动登录
    func isAutoLogin() -> Bool {
        return ud.bool(forKey: IsAuto)
    }
    
    /// 保存登录信息
    /// - Parameters:
    ///   - account: 账号
    ///   - password: 密码
    ///   - userId: 用户ID
    func saveLoginInfo(_ account: String, password: String, userId: String) {
        ud.set(account, forKey: LoginAccount)
        ud.set(userId, forKey: LoginUserID)
        savePassword(password)
        
        ud.synchronize()
    }
    
    /// 保存密码
    func savePassword(_ password: String) {
        ud.set(password, forKey: LoginPassword)
    }
    
    /// 获取账号
    func account() -> String {
        return ud.object(forKey: LoginAccount) as? String ?? ""
    }
    
    /// 获取密码
    func password() -> String {
        return ud.object(forKey: LoginPassword) as? String ?? ""
    }
    
    /// 获取用户ID
    func userID() -> String {
        return ud.object(forKey: LoginUserID) as? String ?? ""
    }
    
    /// 清除登录状态
    func clearCount() {
        ud.set("", forKey: LoginAccount)
        ud.set("", forKey: LoginPassword)
        ud.set("", forKey: LoginUserID)

        setIsAutoLogin(false)
    }
}

// MARK: - Device Token
public extension AppAccountConfig {
    /// 保存 token
    func saveToken(_ token: String) {
        ud.set(token, forKey: DeviceToken)
        ud.synchronize()
    }
    
    /// 获取 toke
    func token() -> String {
        return ud.object(forKey: DeviceToken) as? String ?? ""
    }
    
    func registerDeviceToken(_ deviceToken: Data) {
        let string = deviceToken.description
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: "<", with: "")
        
        saveToken(string)
    }
    
}
