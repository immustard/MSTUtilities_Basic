//
//  MSTPageStyle.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/19.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

public class MSTPageStyle {
    
    /// titleView
    public var titleViewHeight: CGFloat = 44
    public var titleColor: UIColor = UIColor.black
    public var titleSelectedColor: UIColor = UIColor.blue
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    public var titleViewBackgroundColor: UIColor = UIColor.white
    public var titleMargin: CGFloat = 30
    /// 标题到边框距离(当宽度非固定时生效)
    public var titlePadding: CGFloat = 0
    public var titleViewSelectedColor: UIColor = UIColor.clear
    public var titleItemWidth: CGFloat = 0
    
    /// titleView滑动
    public var isTitleViewScrollEnabled: Bool = false
    
    /// title下划线
    public var isShowBottomLine: Bool = false
    public var bottomLineColor: UIColor = UIColor.blue
    public var bottomLineHeight: CGFloat = 2
    public var bottomLineWidth: CGFloat = 0
    public var bottomLineRadius: CGFloat = 1
    
    // titleView 分割线
    public var isShowSplitLine: Bool = false
    public var splitLineHeight: CGFloat = 1
    public var splitLineColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
    
    /// title缩放
    public var isTitleScaleEnabled: Bool = false
    public var titleMaximumScaleFactor: CGFloat = 1.2
    
    /// title遮罩
    public var isShowCoverView: Bool = false
    public var isCoverViewSlide: Bool = true
    public var coverViewBgColor: UIColor = .black
    public var coverViewAlpha: CGFloat = 0.4
    public var coverMargin: CGFloat = 8
    public var coverViewHeight: CGFloat = 25
    public var coverViewRadius: CGFloat = 12
    
    // title背景
    public var isShowTitleBgView: Bool = false
    public var titleBgViewColor: UIColor = .clear
    public var titleBgViewHeight: CGFloat = 30
    public var titleBgViewHorizantalInset: CGFloat = 0
    public var isTitleBgViewCircle: Bool = false
    
    /// contentView
    public var isContentScrollEnabled : Bool = true
    public var contentViewBackgroundColor = UIColor.white
    
    
    public init() {
        
    }
}
