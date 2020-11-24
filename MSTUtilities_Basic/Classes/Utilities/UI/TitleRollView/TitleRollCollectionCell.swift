//
//  TitleRollCollectionCell.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/12/9.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

class TitleRollCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    var titleStr = "" {
        didSet {
            _titleLabel.text = self.titleStr
        }
    }
    
    var imgStr = "" {
        didSet {
            _imgView.image = UIImage(named: self.imgStr)
        }
    }
    
    // MARK: - Lazy Loady
    private lazy var _titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14)
        
        self.contentView.addSubview(label)
        
        return label
    }()
    
    private lazy var _imgView: UIImageView = {
        let imgView = UIImageView()
        
        self.contentView.addSubview(imgView)
        
        return imgView
    }()
    
    // MARK: - Instance Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !kStrIsEmpty(imgStr) {
            _imgView.frame = CGRect(x: 0, y: (self.mst_height-14)/2, width: 28, height: 14)
        } else {
            _imgView.frame = CGRect(x: 0, y: 0, width: 28, height: 14)
        }
        
        _titleLabel.frame = CGRect(x: _imgView.mst_right + 5, y: 0, width: mst_width - _imgView.mst_right-5, height: mst_height)
    }

}
