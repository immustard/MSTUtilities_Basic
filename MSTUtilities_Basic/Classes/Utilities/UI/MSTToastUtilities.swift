//
//  MSTToastUtilities.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/26.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit
import PKHUD

private let ToastDuration: TimeInterval = 1.5
private let HideDuration: TimeInterval = 1

// MARK: - 显示
public class MSTToastUtilities {
    
    /// 显示菊花提示
    /// - Parameters:
    ///   - title: 标题(在菊花上)
    ///   - subtitle: 副标题(在菊花下)
    ///   - view: 展示在哪个视图上, 为空时展示在 keyWindow 上
    public class func showToast(title: String?, subtitle: String?, onView view: UIView?) {
        let progressView = PKHUDProgressView(title: title, subtitle: subtitle)
        progressView.titleLabel.numberOfLines = 0
        PKHUD.sharedHUD.contentView = progressView
        PKHUD.sharedHUD.show(onView: view)
    }
    
    /// 显示菊花提示, 并自动隐藏
    /// - Parameters:
    ///   - title: 标题(在菊花上)
    ///   - subtitle: 副标题(在菊花下)
    ///   - view: 展示在哪个视图上, 为空时展示在 keyWindow 上
    ///   - completion: 隐藏时回调
    public class func showToastAndDelayHide(title: String?, onView view: UIView?, completion: (() -> Void)?) {
        let progressView = PKHUDTextView(text: title)
        progressView.titleLabel.numberOfLines = 0
        PKHUD.sharedHUD.contentView = progressView
        PKHUD.sharedHUD.show(onView: view)
        PKHUD.sharedHUD.hide(afterDelay: ToastDuration) { (finish) in
            completion?()
        }
    }
    
    /// 显示成功提示, 并自动隐藏
    /// - Parameters:
    ///   - title: 标题(在菊花上)
    ///   - subtitle: 副标题(在菊花下)
    ///   - view: 展示在哪个视图上, 为空时展示在 keyWindow 上
    ///   - completion: 隐藏时回调
    public class func showSuccessToastAndDelayHide(title: String?, subtitle: String?, onView view: UIView?, completion: (() -> Void)?) {
        let progressView = PKHUDSuccessView(title: title, subtitle: subtitle)
        progressView.titleLabel.numberOfLines = 0
        PKHUD.sharedHUD.contentView = progressView
        PKHUD.sharedHUD.show(onView: view)
        PKHUD.sharedHUD.hide(afterDelay: ToastDuration) { (finish) in
            completion?()
        }
    }
    
    /// 显示失败提示, 并自动隐藏
    /// - Parameters:
    ///   - title: 标题(在菊花上)
    ///   - subtitle: 副标题(在菊花下)
    ///   - view: 展示在哪个视图上, 为空时展示在 keyWindow 上
    ///   - completion: 隐藏时回调
    public class func showFailureToastAndDelayHide(title: String?, subtitle: String?, onView view: UIView?, completion: (() -> Void)?) {
        let progressView = PKHUDErrorView(title: title, subtitle: subtitle)
        progressView.titleLabel.numberOfLines = 0
        PKHUD.sharedHUD.contentView = progressView
        PKHUD.sharedHUD.show(onView: view)
        PKHUD.sharedHUD.hide(afterDelay: ToastDuration) { (finish) in
            completion?()
        }
    }
}

public extension MSTToastUtilities {
    
    /// 隐藏提示
    class func hideToast(_ animated: Bool) {
        PKHUD.sharedHUD.hide(animated)
    }
    
    /// 延时隐藏提示
    class func delayHideToast() {
        PKHUD.sharedHUD.hide(afterDelay: ToastDuration)
    }
    
    /// 隐藏并提示成功
    /// - Parameters:
    ///   - title: 标题(在菊花上)
    ///   - subtitle: 副标题(在菊花下)
    ///   - view: 展示在哪个视图上, 为空时展示在 keyWindow 上
    ///   - completion: 隐藏时回调
    class func hideToastSuccessfully(title: String?, subtitle: String?, onView view: UIView?, completion: (() -> Void)?) {
        let progressView = PKHUDSuccessView(title: title, subtitle: subtitle)
        progressView.titleLabel.numberOfLines = 0
        PKHUD.sharedHUD.contentView = progressView
        PKHUD.sharedHUD.show(onView: view)
        PKHUD.sharedHUD.hide(afterDelay: HideDuration) { (finish) in
            completion?()
        }
    }
    
    /// 隐藏并提示失败
    /// - Parameters:
    ///   - title: 标题(在菊花上)
    ///   - subtitle: 副标题(在菊花下)
    ///   - view: 展示在哪个视图上, 为空时展示在 keyWindow 上
    ///   - completion: 隐藏时回调
    class func hideToastFailed(title: String?, subtitle: String?, onView view: UIView?, completion: (() -> Void)?) {
        let progressView = PKHUDErrorView(title: title, subtitle: subtitle)
        progressView.titleLabel.numberOfLines = 0
        PKHUD.sharedHUD.contentView = progressView
        PKHUD.sharedHUD.show(onView: view)
        PKHUD.sharedHUD.hide(afterDelay: HideDuration) { (finish) in
            completion?()
        }
    }
}
