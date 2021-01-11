//
//  MSTTools_Language.swift
//  MSTUtilities_Basic
//
//  Created by Mustard on 2020/12/21.
//

import Foundation

public extension MSTTools {
    static func localizedLanguage(key: String) -> String {
        let languageBundle = Bundle.getLanguageBundle() ?? Bundle.main
        
        return NSLocalizedString(key, tableName: "Localizable", bundle: languageBundle, value: "?", comment: key)
    }
}
