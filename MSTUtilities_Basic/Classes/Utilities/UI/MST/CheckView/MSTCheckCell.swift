//
//  MSTCheckCell.swift
//  Volunteerism
//
//  Created by Mustard on 2020/7/28.
//  Copyright © 2020 Mustard. All rights reserved.
//

import UIKit

class MSTCheckCell: UITableViewCell {

    // MARK: - Lazy Load
    private lazy var _imgView: UIImageView = {
        let view = UIImageView()
        
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 15)
        label.textColor = .mst_color(light: kHexColor("#333333"), dark: kHexColor("#CCCCCC"))
        
        return label
    }()
    
    // MARK: - Initial Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        p_initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Instance Methods
extension MSTCheckCell {
    func updateCheck(_ isCheck: Bool) {
        _imgView.image = UIImage(named: isCheck ? "mst_check_sel" : "mst_check_nor", in: kMSTBundle, compatibleWith: nil)
    }
}

// MARK: - Private Methods
private extension MSTCheckCell {
    func p_initView() {
        selectionStyle = .none
        
        contentView.addSubview(_imgView)
        _imgView.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(30)
            maker.leading.equalTo(20)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (maker) in
            maker.leading.equalTo(_imgView.snp.trailing)
            maker.top.bottom.equalToSuperview().inset(12)
            maker.trailing.equalToSuperview().inset(20)
        }
        
        let line = UIView()
        line.backgroundColor = .mst_color(light: kHexColor("#F3F4F5"), dark: kHexColor("#191A1B"))
        contentView.addSubview(line)
        line.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(20)
            maker.height.equalTo(1)
            maker.bottom.equalToSuperview()
        }
    }
}

