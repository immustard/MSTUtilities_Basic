//
//  MSTTools_Device.swift
//  Reader
//
//  Created by 张宇豪 on 2019/7/19.
//  Copyright © 2019 Mustard. All rights reserved.
//

import UIKit

public extension MSTTools {
    // MARK: - Device Information
    var deviceName: String {
        return UIDevice.current.name
    }
    
    var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    // MARK: - Application Information
    private var _infoDictionary: [String: Any]? {
        return Bundle.main.infoDictionary
    }
    
    var bundleName: String? {
        return _infoDictionary?["CFBundleName"] as? String
    }
    
    var appVersion: String? {
        return _infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var appBuild: String? {
        return _infoDictionary?["CFBundleVersion"] as? String
    }
    
    var appIcon: UIImage? {
        if let icons = _infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    
    // MARK: - Class Methods
    class func isIphoneX() -> Bool {
        return MSTTools.shared.p_isIphoneX()
    }
    
    // MARK - Private Methods
    private func p_isIphoneX() -> Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
            return (bottom > 0.0)
        } else {
            return false
        }
    }
}
