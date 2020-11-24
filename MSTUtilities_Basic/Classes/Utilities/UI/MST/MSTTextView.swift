//
//  MSTTextView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/12/6.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

public typealias TextChangeClosure = (String) -> Void

public class MSTTextView: UITextView {

    // MARK: - Properties
    /// 输入最大字数限制
    @IBInspectable public var maxCount: UInt = 0
    /// 是否可以输入 emoji 表情
    @IBInspectable public var isAllowEmoji: Bool = true
    /// 输入到最大时是否提示
    @IBInspectable public var isShowAlert: Bool = true
    /// 输入到最大时是否需要截断
    @IBInspectable public var isNeedIntercept: Bool = false
    
    /// 占位符
    @IBInspectable public var placeholder: String = "" {
        didSet {
            self._placeholderLabel.text = self.placeholder
        }
    }
    /// 占位符颜色
    @IBInspectable public var placeholderColor: UIColor = kColorCCC {
        didSet {
            self._placeholderLabel.textColor = self.placeholderColor
        }
    }
    
    public override var font: UIFont? {
        didSet {
            self._placeholderLabel.font = self.font
            self._countLabel.font = self.font
        }
    }
    
    public override var textColor: UIColor? {
        didSet {
            self._countLabel.textColor = self.textColor
        }
    }
    
    public override var textContainerInset: UIEdgeInsets {
        didSet {
            if _isShowCount {
                super.textContainerInset = UIEdgeInsets(top: self.textContainerInset.top, left: self.textContainerInset.left, bottom: self.textContainerInset.bottom + 20, right: self.textContainerInset.right)
            }
        }
    }
    
    /// 显示文字
    public override var text: String! {
        willSet {
            if kStrIsEmpty(self.placeholder) {
                self._placeholderLabel.isHidden = true
            } else {
                self._placeholderLabel.isHidden = !kStrIsEmpty(newValue)
            }
        }
        didSet {
            // 解决大段复制, 内容弹上去的问题
            self.scrollRangeToVisible(self.selectedRange)
        }
    }

    /// 文字修改回调
    private var _changeClosure: ((String) -> Void)?
    
    private var _currentText = ""

    private var _isShowCount = false
    
    // MARK: - Lazy Load
    private lazy var _placeholderLabel: MSTLabel = {
        let label = MSTLabel()
        
        label.verticalAlignment = .top
        label.numberOfLines = 0
        label.text = self.placeholder
        label.textColor = self.placeholderColor
        label.font = self.font

        return label
    }()
    
    private lazy var _countLabel: UILabel = {
        let label = UILabel()
        
        label.text = "0/\(maxCount)"
        label.font = self.font
        label.textColor = self.textColor
        label.textAlignment = .right
        
        return label
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Initial Methods
public extension MSTTextView {
    class func textView(maxCount: UInt, allowEmoji isAllowEmoji: Bool, needIntercrept isNeedIntercept: Bool, showAlert isShowAlert: Bool, showCount isShowCount: Bool = false, changeClosure: TextChangeClosure?) -> MSTTextView {
        return MSTTextView(maxCount: maxCount, allowEmoji: isAllowEmoji, needIntercrept: isNeedIntercept, showAlert: isShowAlert, showCount: isShowCount, changeClosure: changeClosure)
    }
    
    convenience init(maxCount: UInt, allowEmoji isAllowEmoji: Bool, needIntercrept isNeedIntercept: Bool, showAlert isShowAlert: Bool, showCount: Bool = false, changeClosure: TextChangeClosure?) {
        self.init()
        
        self.delegate = self
        if #available(iOS 11.0, *) {
            self.pasteDelegate = self
        }
        self.maxCount = maxCount
        self.isAllowEmoji = isAllowEmoji
        self.isShowAlert = isShowAlert
        self.isNeedIntercept = isNeedIntercept
        _isShowCount = showCount
        _changeClosure = changeClosure

        p_setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        p_setupUI()
    }
}

// MARK: - Instance Methods
extension MSTTextView {
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        _countLabel.frame = CGRect(x: textContainerInset.left + 4, y: self.mst_height - 12 - 2 - 20, width: mst_width - textContainerInset.left - textContainerInset.right - 4*2, height: 20)
        
        _placeholderLabel.frame = CGRect(x: textContainerInset.left + 4, y: textContainerInset.top + 2, width: mst_width - textContainerInset.left - textContainerInset.right - 4*2, height: self.mst_height - 12 - 2*2)
    }
    
    public func setChangeClosure(_ closure: @escaping (String) -> Void) {
        _changeClosure = closure
    }
    
    private func p_setupUI() {
        // 解决 contentSize 超过 textView.frame 是, 底部输入乱跳的问题
        layoutManager.allowsNonContiguousLayout = false
        
        addSubview(_placeholderLabel)
        addSubview(_countLabel)

        _countLabel.isHidden = !_isShowCount
    }
    
    private func p_analyse() {
        if text.mst_charLength > maxCount && self.maxCount != 0 {
            _currentText = text
            
            // 需要被截断
            if isNeedIntercept {
                // 截取之前判断是否含有非法字符
                if !kStrIsEmpty(_currentText) {
                    while _currentText.utf8.count == 0 {
                        _currentText = _currentText.mst_substring(to: _currentText.mst_charLength-1) ?? ""
                    }
                }
                
                // 截取字符串
                _currentText = _currentText.mst_substring(to: Int(maxCount)) ?? ""
                
                // 截取之后判断是否含有非法字符
                if !kStrIsEmpty(_currentText) {
                    while _currentText.utf8.count == 0 {
                        _currentText = _currentText.mst_substring(to: _currentText.mst_charLength-1) ?? ""
                    }
                }
                
                text = _currentText
            }
            
            if isShowAlert {
                MSTToastUtilities.showFailureToastAndDelayHide(title: "最多输入\(maxCount)字", subtitle: nil, onView: nil, completion: nil)
            }
        } else {
            if !isAllowEmoji && text.mst_containEmoji {
                if !kStrIsEmpty(_currentText) {
                    while _currentText.utf8.count == 0 {
                        _currentText = _currentText.mst_substring(to: _currentText.mst_charLength-1) ?? ""
                    }
                }
                
                text = _currentText
                
                MSTToastUtilities.showFailureToastAndDelayHide(title: "不能输入表情符", subtitle: nil, onView: nil, completion: nil)
            } else {
                _currentText = text
                
                if !kStrIsEmpty(_currentText) {
                    while _currentText.utf8.count == 0 {
                        _currentText = _currentText.mst_substring(to: _currentText.mst_charLength-1) ?? ""
                    }
                }
            }
        }
        
        _changeClosure?(_currentText)
    }
}

// MARK: - UITextViewDelegate
extension MSTTextView: UITextViewDelegate, UITextPasteDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        let selectedRange = markedTextRange
        
        guard selectedRange != nil else {
            p_analyse()
            _placeholderLabel.isHidden = text.mst_charLength > 0
            
            return
        }
        
        p_analyse()

        _placeholderLabel.isHidden = text.mst_charLength > 0
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        _currentText = self.text
        
        return true
    }
    
    public override func paste(_ sender: Any?) {
        super.paste(sender)
        
        if _isShowCount {
            _countLabel.text = "\(self.text.mst_charLength)/\(maxCount)"
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if _isShowCount {
            if text == "" {
                _countLabel.text = "\(max(self.text.mst_charLength-1, 0))/\(maxCount)"
            } else {
                _countLabel.text = "\(self.text.mst_charLength+text.mst_charLength)/\(maxCount)"
            }
        }

        return true
    }
}
