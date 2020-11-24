//
//  MSTMenuView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/15.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

@objc public protocol MSTMenuViewDelegate {
    @objc optional func menuViewDidSelectedRow(menuView: MSTMenuView, index: Int)
}

open class MSTMenuView: UIView, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    /// 显示文字列表
    public var titleArray: Array<String>? {
        didSet {
            let height = min(CGFloat(titleArray?.count ?? 0)*_rowHeight, _maxHeight)
            _resultFrame.size.height = height
            _tableView.frame = CGRect(x: _resultFrame.minX, y: _resultFrame.minY, width: _resultFrame.width, height: 0)

            _tableView.reloadData()
        }
    }
    
    public weak var delegate: MSTMenuViewDelegate?
    
    private var _resultFrame: CGRect!
    
    private let _cellID = "MSTMenuViewCellID"
    
    private let _rowHeight: CGFloat = 35

    private var _maxHeight: CGFloat = 0
    
    private let _duration: TimeInterval = 0.26

    // MARK: - Initial Methods
    /// 创建方法
    /// - Parameters:
    ///   - frame: 其中 height 为最大高度, 当不足时, 自动适配(最小高度为35)
    ///   - titleArray: 显示文字
    public init(frame: CGRect, titleArray: Array<String>) {
        super.init(frame: CGRect.zero)
        
        clipsToBounds = true

        var mHeight = max(35, frame.height)
        _maxHeight = mHeight
        mHeight = min(CGFloat(titleArray.count)*_rowHeight, _maxHeight)

        _resultFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: mHeight)
        
        self.titleArray = titleArray
        self.backgroundColor = .white
        
        _tableView.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 0)
        self.addSubview(_tableView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Instance Methods
    public func show() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(_bgBtn)
        window?.addSubview(_tableView)
        
        UIView.animate(withDuration: _duration) {
            self._tableView.frame = self._resultFrame
        }
    }
    
    @objc public func hide() {
        UIView.animate(withDuration: _duration, animations: {
            self._tableView.frame = CGRect(x: self._resultFrame.minX, y: self._resultFrame.minY, width: self._resultFrame.width, height: 0)
        }, completion: { (finish) in
            self._bgBtn.removeFromSuperview()
            self._tableView.removeFromSuperview()
        })
    }
    
    // MARK: - UITableViewDataSource & Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellID)!
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.text = titleArray?[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 12)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        
        let lineView = UIView(frame: CGRect(x: 0, y: 34, width: _resultFrame?.width ?? 0, height: 1))
        lineView.backgroundColor = .white
        cell.contentView.addSubview(lineView)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        delegate?.menuViewDidSelectedRow?(menuView: self, index: indexPath.row)
    }
    
    // MARK: - Lazy Load
    private lazy var _tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 6
        tableView.backgroundColor = UIColor.darkGray
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = _rowHeight

        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: _cellID)
        
        return tableView
    }()

    private lazy var _bgBtn: UIButton = {
        let btn = UIButton(type: .custom)
        
        btn.frame = UIScreen.main.bounds
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(hide), for: .touchUpInside)
        
        return btn
    }()
}
