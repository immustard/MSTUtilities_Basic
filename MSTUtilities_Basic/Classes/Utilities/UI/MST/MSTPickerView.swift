//
//  MSTPickerView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/12/17.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

public enum MSTPickerViewType {
    case alert  // 中间
    
    case sheet  // 底部
}

@objc public protocol MSTPickerViewDelegate {
    /// 点击确认按钮之后回调
    /// - Parameters:
    ///   - pickerView: 滚动选择视图
    ///   - Index: 选择索引
    ///   - object: 选择数据, 可为空
    @objc optional func pickerView(_ pickerView: MSTPickerView, didSelectedAt index: Int, object: Any?)
    
    @objc optional func pickerViewDidCancel(_ pickerView: MSTPickerView)
}

public class MSTPickerView: UIView {

    // MARK: - Properties
    /// 展示方式
    public var type: MSTPickerViewType = .alert {
        didSet {
            p_setupUI()
        }
    }
    
    /// 标题
    public var title: String = "" {
        didSet {
            _titleLabel.text = self.title
        }
    }
    
    /// 数据源
    public var titlesArray: [String] = ["暂无更多数据"] {
        didSet {
            if self.titlesArray.count == 0 {
                self.titlesArray.append("暂无更多数据")
            }
            _pickerView.reloadAllComponents()
        }
    }
    
    /// 数据存储, 回调时用
    public var objectArray: [Any]?
    
    public var currentIndex: Int? {
        didSet {
            guard self.currentIndex ?? -1 < titlesArray.count else {
                return
            }
            
            _pickerView.selectRow(self.currentIndex!, inComponent: 0, animated: false)
        }
    }
    
    public var currentValue: String? {
        didSet {
            if let str = self.currentValue {
                if let idx = titlesArray.firstIndex(of: str) {
                    _pickerView.selectRow(idx, inComponent: 0, animated: false)
                }
            }
        }
    }

    /// 代理
    public var delegate: MSTPickerViewDelegate?
    
    private var _isShowAnimated: Bool = false
    
    private var _currentIdx: Int = 0

    // MARK: - Lazy Load
    private lazy var _bgBtn: UIButton = {
        let btn = UIButton(type: .custom)

        btn.frame = UIScreen.main.bounds
        btn.addTarget(self, action: #selector(p_tapAction(_:event:)), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var _bgView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        view.clipsToBounds = true
        self.addSubview(view)
        
        return view
    }()
    
    private lazy var _titleLabel: UILabel = {
        let label = UILabel()

        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = kHexColor("333333")
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        self._bgView.addSubview(label)

        return label
    }()
    
    private lazy var _cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)

        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(kHexColor("#333333"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(p_cancelAction), for: .touchUpInside)
        self._bgView.addSubview(btn)
        
        return btn
    }()
    
    private lazy var _confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(kHexColor("#6AA7D3"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(p_confirmAction), for: .touchUpInside)
        self._bgView.addSubview(btn)

        return btn
    }()
    
    private lazy var _pickerView: UIPickerView = {
        let view = UIPickerView()
        
        view.dataSource = self
        view.delegate = self
        self._bgView.addSubview(view)

        return view
    }()
    
    // MARK: - Initial Methods
    convenience public init(title: String, type: MSTPickerViewType) {
        self.init()
        
        self.title = title
        self.type = type
        
        p_setupUI()
    }
}

// MARK: - Private Methods
private var BtnWidth: CGFloat = 60
private let BtnHeight: CGFloat = 40

private extension MSTPickerView {
    func p_setupUI() {
        frame = UIScreen.main.bounds
        
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addSubview(_bgBtn)

        if type == .alert {
            BtnWidth = 60
            
            _bgView.mst_cornerRadius(radius: 4)
            _bgView.frame = CGRect(x: 36, y: kScreenHeight/2-140, width: kScreenWidth-36*2, height: 300)
        } else {
            BtnWidth = 80
            
            _bgView.mst_cornerRadius(radius: 0)
            _bgView.frame = CGRect(x: 0, y: kScreenHeight-360, width: kScreenWidth, height: 360)
        }
        
        _titleLabel.text = title
        
        _cancelBtn.frame = CGRect(x: 0, y: 0, width: BtnWidth, height: BtnHeight)
        _confirmBtn.frame = CGRect(x: _bgView.mst_width-BtnWidth, y: 0, width: BtnWidth, height: BtnHeight)
        _titleLabel.frame = CGRect(x: BtnWidth, y: 0, width: _bgView.mst_width - 2*BtnWidth, height: BtnHeight)
        _pickerView.frame = CGRect(x: 0, y: BtnHeight, width: _bgView.mst_width, height: _bgView.mst_height-BtnHeight)
    }
    
    func p_clearSeparator() {
        for line in _pickerView.subviews {
            if line.mst_height < 1 {
                line.backgroundColor = .clear
            }
        }
    }
}

// MARK: - Actions
extension MSTPickerView {
    @objc private func p_confirmAction() {
        var data: Any? = nil
        
        if !kArrIsEmpty(objectArray) {
            if objectArray!.count > _currentIdx {
                data = objectArray![_currentIdx]
            }
        }

        delegate?.pickerView?(self, didSelectedAt: _currentIdx, object: data)

        p_hide()
    }
    
    @objc private func p_cancelAction() {
        delegate?.pickerViewDidCancel?(self)

        p_hide()
    }
    
    @objc private func p_tapAction(_ sender: UIButton, event: UIEvent) {
        if let touch = event.touches(for: sender)?.first {
            let point = touch.location(in: self)
            
            // 用这个方法判断是否响应事件
            if !point.equalTo(CGPoint(x: 0, y: kScreenHeight)) { // 点击到空白处
                p_cancelAction()
            }
        }
    }
    
    public func show(_ animated: Bool) {
        _isShowAnimated = animated

        if animated {
            self.alpha = 0
            self._bgView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)

            UIApplication.shared.keyWindow?.addSubview(self)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 1

                if self.type == .alert {
                    self._bgView.transform = .identity
                } else {
                    self._bgView.mst_top = kScreenHeight-self._bgView.mst_height
                }
            }) { (finished) in

            }
        } else {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
    }
    
    private func p_hide() {
        if _isShowAnimated {
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0

                if self.type == .alert {
                    self._bgView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                } else {
                    self._bgView.mst_top = kScreenHeight
                }
            }) { (finished) in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }
}

extension MSTPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titlesArray.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        p_clearSeparator()
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = kHexColor("333333")
        label.text = titlesArray[row]
        
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titlesArray[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _currentIdx = row
    }
}
