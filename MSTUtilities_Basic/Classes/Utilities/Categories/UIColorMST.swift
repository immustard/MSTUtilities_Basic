//
//  UIColorMST.swift
//  MSTTools_Swift
//
//  Created by 张宇豪 on 2017/6/15.
//  Copyright © 2017年 张宇豪. All rights reserved.
//

import UIKit

public typealias mstColorRGB = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

public extension UIColor {
    static var mst_random: UIColor {
        return UIColor(red: CGFloat(arc4random()%256)/255, green: CGFloat(arc4random()%256)/255, blue: CGFloat(arc4random()%256)/255, alpha: 1)
    }

    // MARK: - Class Methodss
    class func mst_color(light lightColor: UIColor, dark darkColor: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return darkColor
                } else {
                    return lightColor
                }
            }
        } else {
            return lightColor
        }
    }
    
    class func mst_RGBColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return mst_RGBAColor(r: r, g: g, b: b, a: 1)
    }
    
    class func mst_RGBAColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor(r: r, g: g, b: b, alpha: a)
    }
    
    static func mst_colorWithHexString(_ hexString: String) -> UIColor {
        var alpha, red, blue, green: CGFloat

        let colorString = hexString.replacingOccurrences(of: "#", with: "").uppercased()
        switch colorString.mst_charLength {
        case 3: // RGB
            alpha = 1
            red = p_colorComponent(fromStrig: colorString, start: 0, length: 1)
            green = p_colorComponent(fromStrig: colorString, start: 1, length: 1)
            blue = p_colorComponent(fromStrig: colorString, start: 2, length: 1)
        case 4: // ARGB
            alpha = p_colorComponent(fromStrig: colorString, start: 0, length: 1)
            red = p_colorComponent(fromStrig: colorString, start: 1, length: 1)
            green = p_colorComponent(fromStrig: colorString, start: 2, length: 1)
            blue = p_colorComponent(fromStrig: colorString, start: 3, length: 1)
        case 6: // RRGGBB
            alpha = 1
            red = p_colorComponent(fromStrig: colorString, start: 0, length: 2)
            green = p_colorComponent(fromStrig: colorString, start: 2, length: 2)
            blue = p_colorComponent(fromStrig: colorString, start: 4, length: 2)
        case 8: // AARRGGBB
            alpha = p_colorComponent(fromStrig: colorString, start: 0, length: 2)
            red = p_colorComponent(fromStrig: colorString, start: 2, length: 2)
            green = p_colorComponent(fromStrig: colorString, start: 4, length: 2)
            blue = p_colorComponent(fromStrig: colorString, start: 6, length: 2)
        default:
            return UIColor.white
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: - Initial Methods
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    // MARK: - Instance Methods
    func mst_getRGB() -> mstColorRGB {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red*255.0, green*255.0, blue*255.0, alpha*255.0)
    }
    
    func mst_hexString(_ inclueAlpha: Bool = true) -> String {
        let rgb = mst_getRGB()
        
        if !inclueAlpha {
            let intRGB = Int(rgb.red)<<16 | Int(rgb.green)<<8 | Int(rgb.blue)<<0
            
            return String(format: "#%06X", intRGB)
        } else {
            let intRGB = Int(rgb.alpha)<<24 | Int(rgb.red)<<16 | Int(rgb.green)<<8 | Int(rgb.blue)<<0
            
            return String(format: "#%08X", intRGB)
        }
    }

    // MARK - Private Methods
    private static func p_colorComponent(fromStrig string: String, start: Int, length: Int) -> CGFloat {
        let substring = string.mst_substring(range: Range(start...start+length))!
        let fullHex = length == 2 ? substring : "\(substring)\(substring)"
        
        var hexComponent: UInt32 = 0
        Scanner(string: fullHex).scanHexInt32(&hexComponent)

        return CGFloat(hexComponent)/255
    }
}
