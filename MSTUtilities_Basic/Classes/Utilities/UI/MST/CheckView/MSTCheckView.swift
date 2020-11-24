//
//  MSTCheckView.swift
//  Volunteerism
//
//  Created by Mustard on 2020/7/28.
//  Copyright © 2020 Mustard. All rights reserved.
//

import UIKit

private let CellID = "MSTCheckViewCellID"

open class MSTCheckView: UIView {

    // MARK: - Properties
    public var dataSourceArray: [MSTKeyValueModel] = [] {
        didSet {
            selectTitleArray.removeAll()
            selectIDArray.removeAll()
            
            _tableView.reloadData()
        }
    }
    
    /// 标题
    public var title = "" {
        didSet {
            _titleLabel.text = title
        }
    }
    
    /// 选中回调: ([id], [title])
    public var didSelectClosure: (([String], [String]) -> Void)?
    
    public var selectIDArray: [String] = []

    public var selectTitleArray: [String] = []
    
    public var titleColor: UIColor = .black {
        didSet {
            _confirmBtn.setTitleColor(titleColor, for: .normal)
        }
    }

    // MARK: - Lazy Load
    private lazy var _bgBtn: UIButton = {
        let btn = UIButton(type: .custom)
        
        btn.addTarget(self, action: #selector(p_backgroundButtonAction), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var _bgView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .mst_color(light: kHexColor("#FFFFFF"), dark: kHexColor("#000000"))
        view.mst_cornerRadius(radius: 8)
        
        return view
    }()
    
    private lazy var _tableView: UITableView = {
        let view = UITableView(frame: self._bgView.bounds, style: .plain)
        
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.register(MSTCheckCell.self, forCellReuseIdentifier: CellID)
        
        view.dataSource = self
        view.delegate = self
        
        return view
    }()
    
    private lazy var _titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .mst_color(light: kHexColor("#333333"), dark: kHexColor("#cccccc"))
        
        return label
    }()
    
    private lazy var _confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.setTitle("确定", for: .normal)
        btn.addTarget(self, action: #selector(p_confirmAction), for: .touchUpInside)
        
        return btn
    }()
    
    // MARK: - Initial Methods
    public override init(frame: CGRect) {
        super.init(frame: frame)

        p_initView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Instance Methods
public extension MSTCheckView {
    func show() {
        alpha = 0
        isHidden = false

        UIView.animate(withDuration: 0.26) {
            self.alpha = 1
        }
    }
    
    func hide(_ animated: Bool) {
        UIView.animate(withDuration: animated ? 0.26 : 0, animations: {
            self.alpha = 0
        }) { (finished) in
            self.isHidden = true
        }
    }
}

// MARK: - Private Methods
private extension MSTCheckView {
    func p_initView() {
        backgroundColor = kHexColor("666").withAlphaComponent(0.5)
        
        addSubview(_bgBtn)
        _bgBtn.snp.makeConstraints { (maker) in
            maker.leading.trailing.top.bottom.equalToSuperview()
        }

        addSubview(_bgView)
        _bgView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(40)
            maker.top.bottom.equalToSuperview().inset(88)
        }
        
        _bgView.addSubview(_titleLabel)
        _titleLabel.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(20)
            maker.top.equalTo(12)
            maker.height.equalTo(28)
        }
        
        _bgView.addSubview(_confirmBtn)
        _confirmBtn.snp.makeConstraints { (maker) in
            maker.bottom.trailing.equalToSuperview()
            maker.width.equalTo(88)
            maker.height.equalTo(48)
        }
        
        _bgView.addSubview(_tableView)
        _tableView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(_titleLabel.snp.bottom)
            maker.bottom.equalTo(_confirmBtn.snp.top)
        }
    }
}

// MARK: - Actions
extension MSTCheckView {
    @objc private func p_backgroundButtonAction() {
        hide(true)
    }
    
    @objc private func p_confirmAction() {
        selectIDArray.mst_remove("")
        selectTitleArray.mst_remove("")

        didSelectClosure?(selectIDArray, selectTitleArray)
        hide(true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension MSTCheckView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID) as! MSTCheckCell
        
        let model = dataSourceArray[safe: indexPath.row]
        cell.titleLabel.text = model?.value
        
        cell.updateCheck(selectIDArray.contains(kStringFromObj(model?.key)))

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let model = dataSourceArray[indexPath.row]
        let isSelect = selectIDArray.contains(kStringFromObj(model.key))
        
        if isSelect {
            selectIDArray.mst_remove(model.key)
            selectTitleArray.mst_remove(model.value)
        } else {
            selectIDArray.append(model.key)
            selectTitleArray.append(model.value)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
