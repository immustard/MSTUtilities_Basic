//
//  MSTPageView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/19.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

open class MSTPageView: UIView {

    // MARK: - Properties
    private (set) public var style: MSTPageStyle
    private (set) public var titles: [String]
    private (set) public var childViewControllers: [UIViewController]
    private (set) public var startIndex: Int
    private (set) public lazy var titleView = MSTPageTitleView(frame: .zero, style: style, titles: titles, currentIndex: startIndex)
    private (set) public lazy var contentView = MSTPageContentView(frame: .zero, style: style, childViewControllers: childViewControllers, currentIndex: startIndex)

    // MARK: - Initial Methods
    public init(frame: CGRect, style: MSTPageStyle, titles: [String], childViewControllers: [UIViewController], startIndex: Int = 0) {
        self.style = style
        self.titles = titles
        self.childViewControllers = childViewControllers
        self.startIndex = startIndex
        
        super.init(frame: frame)
        
        p_setupUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setChangeClosure(_ closure: @escaping ((Int) -> Void)) {
        contentView.contentViewDidChanged {
            closure(self.contentView.currentIndex)
        }
    }
}

// MARK - Private Methods
extension MSTPageView {
    private func p_setupUI() {
        let titleFrame = CGRect(x: 0, y: 0, width: mst_width, height: style.titleViewHeight)
        titleView.frame = titleFrame
        addSubview(titleView)
        
        let contentFrame = CGRect(x: 0, y: style.titleViewHeight, width: mst_width, height: mst_height - style.titleViewHeight)
        contentView.frame = contentFrame
        addSubview(contentView)
        
        titleView.delegate = contentView
        contentView.delegate = titleView
    }
}
