//
//  LanguageMST.swift
//  MSTUtilities_Basic
//
//  Created by Mustard on 2020/12/21.
//

import Foundation

let kUDCurrentLanguage = "UD_KEY_kUDCurrentLanguage"

extension Bundle {
    class func getLanguageBundle() -> Bundle? {
        // 根据用户选择的不同语言, 获取不同的语言文件
        let title = UserDefaults.standard.object(forKey: kUDCurrentLanguage) as? String ?? ""
        let lanuage = MSTLanguageOptions.getFileName(title: title)
        
        let lanuageBundlePath = Bundle.main.path(forResource: lanuage, ofType: "lproj")
        
        let languageBundle = Bundle(path: lanuageBundlePath!)
        
        guard languageBundle != nil else {
            return nil
        }
        
        return languageBundle!
    }
}

public extension String {
    func mst_localized() -> String {
        let title = UserDefaults.standard.object(forKey: kUDCurrentLanguage) as? String ?? ""
        
        if title == "" {
            return NSLocalizedString(self, comment: self)
        }
        
        return MSTTools.localizedLanguage(key: self)
    }
}
