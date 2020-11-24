//
//  MSTStretchTableHeaderView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/15.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

open class MSTStretchTableHeaderView: UIView {

    // MARK: - Properties
    public var bgImgView: UIImageView!
    
    private var _tableView: UITableView!

    private var _initialFrame: CGRect!
    
    private var _defaultViewHeight: CGFloat!
    
    // MARK: - Initial Methods
    public init(frame: CGRect, tableView: UITableView, imageName: String) {
        super.init(frame: frame)
        
        _tableView = tableView
        
        _initialFrame = frame
        _defaultViewHeight = frame.height
        
        bgImgView = UIImageView(frame: frame)
        bgImgView.image = UIImage(named: imageName)
        addSubview(bgImgView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Instance Methods
    public func resizeView() {
        _initialFrame.size.width = _tableView.frame.width
        self.frame = _initialFrame
    }

    public func srollViewDidScroll(_ scrollView: UIScrollView) {
        var f = bgImgView.frame
        f.size.width = _tableView.frame.width
        bgImgView.frame = f
        
        if scrollView.contentOffset.y < 0 {
            let offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1
            
            _initialFrame = CGRect(x: -offsetY/2, y: -offsetY, width: _tableView.frame.size.width+offsetY, height: _defaultViewHeight+offsetY)
                        
            bgImgView.frame = _initialFrame
        }
    }
    
}
