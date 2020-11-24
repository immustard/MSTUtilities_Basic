//
//  MSTButtonView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/17.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

public protocol MSTButtonViewDelegate: class {
    func buttonViewDidSelected(_ index: Int)
}

public let kMSTBtnViewTitleKey = "MSTBtnViewTitleKey"
public let kMSTBtnViewImageKey = "MSTBtnViewImageKey"

private let _Border: CGFloat = 16

open class MSTButtonView: UIView {
    
    // MARK: - Properties
    public weak var delegate: MSTButtonViewDelegate?
    
    public var titleColor = kColor333 {
        didSet {
            for btn in _btns {
                btn.setTitleColor(titleColor, for: .normal)
            }
        }
    }
    
    public var itemHeight: CGFloat = 96 {
        didSet {
            for btn in _btns {
                btn.snp.updateConstraints { (make) in
                    make.height.equalTo(itemHeight)
                }
                
                self.mst_height = p_calculateViewHeightByButtonsArray()
            }
        }
    }
    
    private var _btns: [UIButton] = []
    
    private var _maxCount = 1

    // MARK: - Class Methods
    public class func buttonView(frame: CGRect, maxCountInRow maxCount: Int, items: Array<Dictionary<String, String>>) -> MSTButtonView {
        let btnView = MSTButtonView(frame: frame)

        if maxCount > 0 {
            btnView._maxCount = maxCount
            
            let itemW = (frame.width-_Border*2) / CGFloat(maxCount)
            
            for (i, dic) in items.enumerated() {
                let row = i / maxCount
                let column = i % maxCount

                let title = dic[kMSTBtnViewTitleKey]!
                let image = dic[kMSTBtnViewImageKey]!
                
                let btn = UIButton(type: .custom)

                btn.tag = i
                btn.titleLabel?.font = .systemFont(ofSize: 16)
                btn.setTitle(title, for: .normal)
                btn.setTitleColor(btnView.titleColor, for: .normal)
                btn.setImage(UIImage(named: image), for: .normal)
                btn.addTarget(btnView, action: #selector(buttionAction(_:)), for: .touchUpInside)

                btnView.addSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.top.equalTo(CGFloat(row)*btnView.itemHeight)
                    make.leading.equalTo(CGFloat(column)*itemW + _Border)
                    make.width.equalTo(itemW)
                    make.height.equalTo(btnView.itemHeight)
                }
                btn.mst_layoutButton(style: .top, spaceBetweenImageAndTitle: 10)
                
                btnView._btns.append(btn)
            }
            
            btnView.mst_height = btnView.p_calculateViewHeightByButtonsArray()
        }
        
        return btnView
    }
    
    // MARK: - Instance Methods
    private func p_calculateViewHeightByButtonsArray() -> CGFloat {
        let maxRow = (_btns.count-1) / _maxCount + 1
        
        let height = CGFloat(maxRow) * itemHeight
        
        return height 
    }

    // MARK: - Actions
    @objc func buttionAction(_ sender: UIButton) {
        delegate?.buttonViewDidSelected(sender.tag)
    }
}
