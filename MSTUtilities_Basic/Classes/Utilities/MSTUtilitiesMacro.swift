//
//  MSTUtilitiesMacro.swift
//  MSTUtilities_Basic
//
//  Created by Mustard on 2020/11/23.
//

import UIKit

var kMSTBundle: Bundle? {
    var path = Bundle.main.url(forResource: "Frameworks", withExtension: nil)!
    path.appendPathComponent("MSTUtilities_Basic")
    path.appendPathExtension("framework")
    path.appendPathComponent("MSTUtilities_Basic")
    path.appendPathExtension("bundle")
    
    return Bundle(url: path)
}

// MARK: - device
public var kIsPhoneX: Bool {
    return MSTTools.isIphoneX()
}


// MARK: - screen
public var kScreenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

public var kScreenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

public var kNavHeight: CGFloat {
    return 44
}

public var kNavAndStatusHeight: CGFloat {
    return kIsPhoneX ? 88 : 64
}

public var kTabHeight: CGFloat {
    return kIsPhoneX ? 83 : 49
}

public var kNavAndTabHeight: CGFloat {
    return kNavHeight + kTabHeight
}

public var kStatusHeight: CGFloat {
    return kIsPhoneX ? 44 : 20
}


// MARK: - color
public var kBgColor: UIColor {
    return UIColor.mst_colorWithHexString("F3F4F5")
}

public var kBgLightColor: UIColor {
    return UIColor.mst_colorWithHexString("FCFCFC")
}

public var kSeporatorLineColor: UIColor {
    return UIColor.mst_colorWithHexString("EEEEEE")
}

public var kColor333: UIColor {
    return UIColor.mst_colorWithHexString("333333")
}

public var kColor666: UIColor {
    return UIColor.mst_colorWithHexString("666666")
}

public var kColor999: UIColor {
    return UIColor.mst_colorWithHexString("999999")
}

public var kColorCCC: UIColor {
    return UIColor.mst_colorWithHexString("cccccc")
}

public var kColorRandom: UIColor {
    return UIColor.mst_random;
}

public func kHexColor(_ string: String) -> UIColor {
    return UIColor.mst_colorWithHexString(string)
}

public var kDynamicColor333: UIColor {
    return .mst_color(light: kHexColor("#333333"), dark: kHexColor("#CCCCCC"))
}

public var kDynamicColor666: UIColor {
    return .mst_color(light: kHexColor("#666666"), dark: kHexColor("#999999"))
}

public var kDynamicColor999: UIColor {
    return .mst_color(light: kHexColor("#999999"), dark: kHexColor("#666666"))
}

public var kDynamicWhite: UIColor {
    return .mst_color(light: kHexColor("#FFFFFF"), dark: kHexColor("#000000"))
}

public var kDynamicBgColor: UIColor {
    return .mst_color(light: kHexColor("#F3F4F5"), dark: kHexColor("#121212"))
}

public var kDynamicPlaceholderColor: UIColor {
    return .mst_color(light: kHexColor("#C4C4C7"), dark: kHexColor("#46464A"))
}

// MARK: - UI
public let kWindow = UIApplication.shared.keyWindow!

// MARK: - String
public func kStringFromObj(_ obj: Any?) -> String {
    guard obj != nil else {
        return ""
    }
    
    var result = ""

    if obj is String {
        result = obj as! String
    } else if obj is Array<Any> {
        result = (obj as! Array<Any>).description
    } else if obj is Dictionary<String, Any> {
        result = (obj as! Dictionary<String, Any>).description
    } else if obj is NSNumber {
        result = (obj as! NSNumber).stringValue
    } else {
        result = "\(String(describing: obj))"
    }
    
    return result
}

// MARK: - Empty
public func kStrIsEmpty(_ string: String?) -> Bool {
    if string == nil {
        return true
    } else {
        return string!.mst_isEmpty
    }
}

public func kStrIsEmptyWithoutBlank(_ string: String?) -> Bool {
    if string == nil {
        return true
    }
    
    let isBlank = p_isBlank(string!)
        
    if isBlank { return true }
    
    return string!.mst_isEmpty
}

public func kArrIsEmpty(_ array: Array<Any>?) -> Bool {
    if array == nil {
        return true
    } else {
        return array!.isEmpty
    }
}

public func kDicIsEmpty(_ dic: Dictionary<String, Any>?) -> Bool {
    if dic == nil {
        return true
    } else {
        return dic!.isEmpty
    }
}

private func p_isBlank(_ string: String) -> Bool {
    for char in string {
        if !char.isWhitespace {
            return false
        }
    }
    return true
}
