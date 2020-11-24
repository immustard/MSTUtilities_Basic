//
//  MSTHistoryViewCell.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/29.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit
import SnapKit

public class MSTHistoryViewCell: UICollectionViewCell {

    // MARK: - Lazy Load
    lazy var button: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(kColor333, for: .normal)
        btn.isUserInteractionEnabled = false
        
        return btn
    }()
    
    // MARK: - Initial Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
   
        self.contentView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(5)
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not benn implemented")
    }
}
