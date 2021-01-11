//
//  StringMST.swift
//  MSTTools_Swift
//
//  Created by 张宇豪 on 2017/6/7.
//  Copyright © 2017年 张宇豪. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

private let DIGIT = "1234567890"
private let LETTER = "abcdefghijklmnopqrstuvwxyz"

public enum MSTRegulation: String {
    /// 未知
    case unknown        = ""
    /// 数字
    case digit          = "^[0-9]+$"
    /// 字母
    case letter         = "^[a-zA-Z]+$"
    /// 大写字母
    case capitalLetter  = "^[A-Z]+$"
    /// 小写字母
    case lowerLetter    = "^[a-z]+$"
    /// 数字和字母
    case digitAndLetter = "^[a-zA-Z0-9]+$"
    /// 汉字
    case hanzi          = "^[\\u4e00-\\u9fa5]+$"
    /// 数字, 字母, 汉字
    case digitLetterHanzi = "^[a-zA-Z0-9\\u4e00-\\u9fa5]+$"
    /// 手机号
    case telephone          = "^((13[0-9])|(14[0-9])|(15[0-9])|(17[0-9])|(18[0-9])|(16[0-9])|(19[0-9]))\\d{8}$"
    /// 身份证
    case idCard             = "(^\\d{15}$)|(^\\d{17}([0-9]|X|x)$)"
}

public enum MSTContainRegulation {
    /// 未知
    case unknown
    /// 数字
    case digit
    /// 字母
    case letter
    /// 大写字母
    case capitalLetter
    /// 小写字母
    case lowerLetter
}

extension String {
    /// 字节长度
    public var mst_byteLength: Int {
        return lengthOfBytes(using: .utf8)
    }
    
    /// 字符长度
    public var mst_charLength: Int {
        return utf16.count
    }
    
    /// 是否包含 emoji
    public var mst_containEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case
            0x00A0...0x00AF,
            0x2030...0x204F,
            0x2120...0x213F,
            0x2190...0x21AF,
            0x2310...0x329F,
            0x1F000...0x1F9CF:
                return true
            default:
                continue
            }
        }
        return false
    }
    
    /// 是否为空
    public var mst_isEmpty: Bool {
        return (
            isEmpty ||
            self == "" ||
            self == "<null>" ||
            self == "(null)" ||
            self == "null"
        )
    }
    
    /// 去掉空白符是否为空
    public var mst_isEmptyWithoutWhiteSpace: Bool {
        return (
            mst_isEmpty ||
            trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).mst_isEmpty
        )
    }
    
    public func mst_check(_ regulation: MSTRegulation) -> Bool {
        guard regulation != .unknown else {
            return false
        }
        let reg = regulation.rawValue

        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        
        if regulation == .idCard {
            if pre.evaluate(with: self) {
                return p_checkIDCard(self)
            } else {
                return false
            }
        } else {
            return pre.evaluate(with: self)
        }
    }
    
    public func mst_contain(_ regulation: MSTContainRegulation) -> Bool {
        guard regulation != .unknown else {
            return false
        }
        
        let cs: CharacterSet?
        
        switch regulation {
        case .digit:
            cs = CharacterSet(charactersIn: DIGIT)
        case .lowerLetter:
            cs = CharacterSet(charactersIn: LETTER)
        case .capitalLetter:
            cs = CharacterSet(charactersIn: LETTER.capitalized)
        case .letter:
            cs = CharacterSet(charactersIn: LETTER + LETTER.capitalized)
        default:
            cs = nil
        }
        
        if cs != nil {
            return (self.rangeOfCharacter(from: cs!) != nil)
        } else {
            return false
        }
    }
}

// MARK: - String
public extension String {
    func mst_substring(startIndex : Int, endIndex : Int) -> String? {
        guard endIndex >= startIndex else { return nil }
        guard endIndex <= mst_charLength else { return nil }
        
        let tStr = NSString(string: self)
        
        let string = tStr.substring(with: NSRange(location: startIndex, length: endIndex-startIndex))
        
        return string
    }
    
    func mst_substring(range: Range<Int>) -> String? {
        return mst_substring(startIndex: range.lowerBound, endIndex: range.upperBound-1)
    }
    
    func mst_substring(range: NSRange) -> String? {
        guard mst_charLength >= range.location+range.length else {
            return nil
        }

        let tStr = NSString(string: self)

        return tStr.substring(with: range)
    }
    
    func mst_substring(to index: Int) -> String? {
        guard mst_charLength >= index else {
            return self
        }
        
        let tStr = NSString(string: self)
        
        return tStr.substring(to: index)
    }
    
    func mst_substring(from index: Int) -> String? {
        guard mst_charLength >= index else {
            return nil
        }
        
        let tStr = NSString(string: self)
        
        return tStr.substring(from: index)
    }
    
    func mst_NSRange(of string: String) -> NSRange {
        let tStr = NSString(string: self)
        
        if tStr.contains(string) {
            return tStr.range(of: string)
        } else {
            return NSRange(location: 0, length: 0)
        }
    }
    
    func mst_range(of string: String) -> Range<Int> {
        let range: NSRange = mst_NSRange(of: string)

        return Range(range)!
    }
}

// MARK: - Calculate
extension String {
    /// 计算文字高度(label)
    ///
    /// - Parameters:
    ///   - width: 给定最大宽度
    ///   - font: 字体
    /// - Returns: 返回文字高度
    public func mst_textHeight(maxWidth width: CGFloat, font: UIFont) -> CGFloat {
        let rect: CGRect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size.height + 2
    }
    
    /// 计算文字宽度(label)
    ///
    /// - Parameters:
    ///   - height: 给定最大高度
    ///   - font: 字体
    /// - Returns: 返回文字宽度
    public func mst_textWidth(maxHeight height: CGFloat, font: UIFont) -> CGFloat {
        let rect: CGRect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size.width + 2
    }
    
    public func mst_textSize(maxSize: CGSize, font: UIFont) -> CGSize {
        let size = NSString(string: self).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
        
        return CGSize(width: size.width + 2, height: size.height + 1)
    }

    /// 计算文字高度(textView)
    ///
    /// - Parameters:
    ///   - textView: 展示文字的 UITextView
    ///   - width: 最大宽度
    /// - Returns: 返回展示高度
    public func mst_textHeight(inTextView textView: UITextView, maxwidth width: CGFloat) -> CGFloat {
        let sizeToFit: CGSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat(MAXFLOAT)))
        
        return sizeToFit.height
    }
}

// MARK: - Json
public extension String {
    func mst_jsonString() -> String {
        return MSTTools.jsonString(fromString: self)
    }
    
    func mst_array() -> Array<Any> {
        return MSTTools.convertToArray(jsonString: self)
    }
    
    func mst_dictionary() -> Dictionary<String, Any> {
        return MSTTools.convertToDictionary(jsonString: self)
    }
}

// MARK: - Conversion
public extension String {
    var mst_intValue: Int {
        return (self as NSString).integerValue
    }
    
    var mst_boolValue: Bool {
        return (self as NSString).boolValue
    }
    
    var mst_doubleValue: Double {
        return (self as NSString).doubleValue
    }
}

// MARK: - Encrypt
public extension String {
    var mst_md5: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        
        return digest.reduce("") { $0 + String(format: "%02x", $1)}
    }
}

// MARK: - Private Methods
private func p_checkIDCard(_ text: String) -> Bool {
    var carid = text
    
    //加权因子
    let R = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
    
    //校验码
    let sChecker: [Int8] = [49,48,88, 57, 56, 55, 54, 53, 52, 51, 50]
    
    //将15位身份证号转换成18位
    let mString = NSMutableString.init(string: text)
    
    if text.mst_charLength == 15 {
        mString.insert("19", at: 6)
        var p = 0
        let pid = mString.utf8String
        for i in 0...16 {
            p += (Int(pid![i])-48) * R[i]
        }
        let o = p % 11
        let stringContent = NSString(format: "%c", sChecker[o])
        mString.insert(stringContent as String, at: mString.length)
        carid = String(mString)
    }
    
    //判断生日是否合法
    let range = NSRange(location: 6, length: 8)
    let datestr: String = (carid as NSString).substring(with: range)
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    if formatter.date(from: datestr) == nil {
        return false
    }
    
    //判断校验位
    if  carid.mst_charLength == 18 {
        //将前17位加权因子保存在数组里
        let idCardY: [String] = ["1", "0", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
        //这是除以11后，可能产生的11位余数、验证码，也保存成数组
        var idCardWiSum: Int = 0
        //用来保存前17位各自乖以加权因子后的总和
        for i in 0..<17 {
            idCardWiSum += carid.mst_substring(range: NSRange(location: i, length: 1))!.mst_intValue * R[i]
        }
        
        let idCardMod: Int = idCardWiSum % 11
        //计算出校验码所在数组的位置
        let idCardLast: String = carid.mst_substring(from: 17)!
        //得到最后一位身份证号码
        //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
        if idCardMod == 2 {
            if idCardLast == "X" || idCardLast == "x" {
                return true
            } else {
                return false
            }
        } else {
            //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
            if (idCardLast as NSString).integerValue == Int(idCardY[idCardMod]) {
                return true
            } else {
                return false
            }
        }
    }
    return false
}

// MARK: - Localizable
public enum MSTLanguageOptions: String {
    case english = "Englist"
    case chinese_simple = "中文(简体)"
    
    public static func getFileName(title: String) -> String {
        switch title {
        case "English":
            return "en"
        case "中文(简体)":
            return "zh-Hans"
        default:
            return "en"
        }
    }
}
