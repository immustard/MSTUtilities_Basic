//
//  MSTImageTitleCollectionViewCell.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/6/28.
//

import UIKit

public let kMSTImageTitleCell_Title = "Title"
public let kMSTImageTitleCell_Image = "Image"

public class MSTImageTitleCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    public var dicionary = [String: String]() {
        didSet {
            _imgView.image = UIImage(named: kStringFromObj(dicionary[kMSTImageTitleCell_Image]))
            _label.text = kStringFromObj(dicionary[kMSTImageTitleCell_Title])
        }
    }
    
    private var _imgView: UIImageView = {
        let imgView = UIImageView()
        
        imgView.contentMode = .center
        
        return imgView
    }()
    
    private var _label: UILabel = {
        let label = UILabel()
        
        label.textColor = kHexColor("333")
        label.font = .systemFont(ofSize: 15)
        
        return label
    }()
    
    // MARK: - Initial Methods
    public override init(frame: CGRect) {
        super.init(frame: frame)

        p_initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Instance Methods
    private func p_initView() {
        contentView.addSubview(_imgView)
        contentView.addSubview(_label)
        
        _imgView.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(64)
            maker.top.centerX.equalToSuperview()
        }
        _label.snp.makeConstraints { (maker) in
            maker.top.equalTo(_imgView.snp.bottom).offset(3)
            maker.centerX.equalToSuperview()
        }
    }
    
}
