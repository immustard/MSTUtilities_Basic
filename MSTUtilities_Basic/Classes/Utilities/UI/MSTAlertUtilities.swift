//
//  MSTAlertUtilities.swift
//  ClipBoard
//
//  Created by Mustard on 2020/6/1.
//  Copyright © 2020 Mustard. All rights reserved.
//

import UIKit
import SCLAlertView

public class MSTAlertUtilities {
    
//    static let shared: AlertUtilities = { return AlertUtilities() }()
    public static func showSuccess(withTitle title: String, subtitle: String?, confirmButtonTitle: String = "确认", buttons: [String]?, completion: ((String?) -> Void)?) {
        let alert = SCLAlertView(appearance: p_appearacne())

        for text in buttons ?? [] {
            let _ = alert.addButton(text) {
                completion?(text)
            }
        }
        
        let _ = alert.addButton(confirmButtonTitle) {
            completion?(confirmButtonTitle)
        }
        
        _ = alert.showSuccess(title, subTitle: subtitle ?? "")
    }
    
    public static func showError(withTitle title: String, subtitle: String?, confirmButtonTitle: String = "确认", buttons: [String]?, completion: ((String?) -> Void)?) {
        let alert = SCLAlertView(appearance: p_appearacne())
        
        for text in buttons ?? [] {
            let _ = alert.addButton(text) {
                completion?(text)
            }
        }
        
        let _ = alert.addButton(confirmButtonTitle) {
            completion?(confirmButtonTitle)
        }
        
        _ = alert.showError(title, subTitle: subtitle ?? "")
    }
    
    public static func showWarning(withTitle title: String, subtitle: String?, confirmButtonTitle: String = "确认", buttons: [String]? = nil, completion: ((String?) -> Void)?) {
        let alert = SCLAlertView(appearance: p_appearacne())

        for text in buttons ?? [] {
            let _ = alert.addButton(text) {
                completion?(text)
            }
        }

        let _ = alert.addButton(confirmButtonTitle) {
            completion?(confirmButtonTitle)
        }
        
        _ = alert.showWarning(title, subTitle: subtitle ?? "")
    }
    
    public static func showInfo(withTitle title: String, subtitle: String?, confirmButtonTitle: String = "确认", buttons: [String]? = nil, completion: ((String?) -> Void)?) {
        let alert = SCLAlertView(appearance: p_appearacne())

        for text in buttons ?? [] {
            let _ = alert.addButton(text) {
                completion?(text)
            }
        }

        let _ = alert.addButton(confirmButtonTitle) {
            completion?(confirmButtonTitle)
        }
        
        _ = alert.showInfo(title, subTitle: subtitle ?? "")
    }
    
    public static func showEditingButtons(withTitle title: String, subtitle: String?, confirmButtonTitle: String = "确认", buttons: [String]?, completion: ((String?) -> Void)?) {
        let alert = SCLAlertView(appearance: p_appearacne())

        for text in buttons ?? [] {
            let _ = alert.addButton(text) {
                completion?(text)
            }
        }
        
        let _ = alert.addButton(confirmButtonTitle) {
            completion?(confirmButtonTitle)
        }
        
        _ = alert.showEdit(title, subTitle: subtitle ?? "")
    }
    
    public static func showEditingField(withTitle title: String, subtitle: String?, confirmButtonTitle: String = "确认", placeholder: String, completion: ((String?) -> Void)?) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTextFieldHeight: 60,
            showCloseButton: true,
            circleBackgroundColor: .mst_color(light: .white, dark: UIColorFromRGB(0x222222)),
            contentViewColor: .mst_color(light: .white, dark: UIColorFromRGB(0x222222)),
            titleColor: .mst_color(light: UIColorFromRGB(0x4D4D4D), dark: UIColorFromRGB(0xf0f0f0))
        )

        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField(placeholder)
        _ = alert.addButton("取消") {
            txt.text = nil
        }
        let responder = SCLAlertViewResponder(alertview: alert)
        responder.setDismissBlock {
            completion?(txt.text)
        }
        _ = alert.showEdit(title, subTitle: subtitle ?? "")
    }
    
    public static func showEditingFields(withTitle title: String, subtitle: String?, confirmButtonTitle: String = "确认", placeholders: [String], completion: (([String]) -> Void)?) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTextFieldHeight: 60,
            showCloseButton: true,
            circleBackgroundColor: .mst_color(light: .white, dark: UIColorFromRGB(0x222222)),
            contentViewColor: .mst_color(light: .white, dark: UIColorFromRGB(0x222222)),
            titleColor: .mst_color(light: UIColorFromRGB(0x4D4D4D), dark: UIColorFromRGB(0xf0f0f0))
        )

        let alert = SCLAlertView(appearance: appearance)
        var txtArr: [UITextField] = []
        
        for ph in placeholders {
            let txt = alert.addTextField(ph)
            txtArr.append(txt)
        }

        _ = alert.addButton("取消") {
            txtArr.forEach { $0.text = nil }
        }
        let responder = SCLAlertViewResponder(alertview: alert)
        responder.setDismissBlock {
            completion?(txtArr.compactMap { $0.text ?? "" })
        }
        _ = alert.showEdit(title, subTitle: subtitle ?? "")
    }
    
    public static func showEditingView(withTitle title: String, subtitle: String?, confirmButtonTitle: String = "确认", textFieldHeight: CGFloat = 96, completion: ((String?) -> Void)?) {
        let appearance = SCLAlertView.SCLAppearance(
          kTextViewdHeight: textFieldHeight,
          showCloseButton: true,
          circleBackgroundColor: .mst_color(light: .white, dark: UIColorFromRGB(0x222222)),
          contentViewColor: .mst_color(light: .white, dark: UIColorFromRGB(0x222222)),
          titleColor: .mst_color(light: UIColorFromRGB(0x4D4D4D), dark: UIColorFromRGB(0xf0f0f0))
        )
        
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextView()
        _ = alert.addButton("取消") {

        }
        let responder = SCLAlertViewResponder(alertview: alert)
        responder.setDismissBlock {
            completion?(txt.text)
        }
        _ = alert.showEdit(title, subTitle: subtitle ?? "")
    }
    
    private static func p_appearacne() -> SCLAlertView.SCLAppearance {
        return SCLAlertView.SCLAppearance(
            showCloseButton: false,
            circleBackgroundColor: .mst_color(light: .white, dark: UIColorFromRGB(0x222222)),
            contentViewColor: .mst_color(light: .white, dark: UIColorFromRGB(0x222222)),
            titleColor: .mst_color(light: UIColorFromRGB(0x4D4D4D), dark: UIColorFromRGB(0xf0f0f0))
        )
    }
}

