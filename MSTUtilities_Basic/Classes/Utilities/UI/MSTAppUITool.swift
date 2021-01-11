//
//  MSTAppUITool.swift
//  MSTUtilities_Basic
//
//  Created by Mustard on 2020/11/23.
//

import UIKit
import Then

public typealias MSTSearchTextChangeClosure = ((String) -> Void)
public typealias MSTSearchTextReturnClosure = ((UITextField) -> Void)

private let SearchViewButtonTag = 99

public class MSTAppUITool: NSObject {
    
    // MARK: - Singleton
    static public let shared: MSTAppUITool = {
        let instance = MSTAppUITool()
        
        return instance
    }()
    
    // MARK: - Properties
    var searchChangeBlocks: [UIView: MSTSearchTextChangeClosure] = [:]
    var searchReturnBlocks: [UIView: MSTSearchTextReturnClosure] = [:]
    
    public static func customNavigationBar(titleColor: UIColor, backgroudColor: UIColor, isShowDivingLine isShow: Bool) {
        UINavigationBar.appearance().tintColor = titleColor
        UINavigationBar.appearance().barTintColor = backgroudColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        if !isShow {
            UINavigationBar.appearance().shadowImage = UIImage()
        }
    }
    
    public static func navigationItem(width: CGFloat, image: String, target: Any, selector: Selector) -> UIBarButtonItem {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        _ = UIButton(type: .system).then {
            $0.frame = view.bounds
            $0.setImage(UIImage(named: image), for: .normal)
            $0.addTarget(target, action: selector, for: .touchUpInside)
            view.addSubview($0)
        }
        
        return UIBarButtonItem(customView: view)
    }
    
    public static func customSearchBar(placeholder: String?, isShowSearchButton: Bool, titleColor: UIColor, textChangedClosure: MSTSearchTextChangeClosure?, textReturnClosure: MSTSearchTextReturnClosure?) -> UIView {
        let height: CGFloat = 44
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: height))
        view.backgroundColor = .white
        
        let textField = UITextField()
        textField.placeholder = placeholder ?? "搜索"
        textField.backgroundColor = kHexColor("#E6E6E6")
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 16)
        textField.mst_cornerRadius(radius: 8)
        textField.returnKeyType = .search
        textField.delegate = MSTAppUITool.shared
        textField.tag = 1

        view.addSubview(textField)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: height))
        let imgView = UIImageView(frame: CGRect(x: (leftView.mst_width-20)/2, y: (height-24)/2, width: 20, height: 20))
        imgView.image = UIImage(named: "search")
        imgView.contentMode = .scaleAspectFit
        leftView.addSubview(imgView)
        
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.addTarget(MSTAppUITool.shared, action: #selector(MSTAppUITool.shared.p_textDidChange(_:)), for: .editingChanged)
        
        if textChangedClosure != nil {
            MSTAppUITool.shared.searchChangeBlocks[textField] = textChangedClosure
        }
        
        if textReturnClosure != nil {
            MSTAppUITool.shared.searchReturnBlocks[textField] = textReturnClosure
        }
        
        if isShowSearchButton {
            let btn = UIButton(type: .custom)
            btn.setTitle("搜索", for: .normal)
            btn.setTitleColor(titleColor, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 16)
            btn.tag = SearchViewButtonTag
            btn.addTarget(MSTAppUITool.shared, action: #selector(MSTAppUITool.shared.p_searchAction(_:)), for: .touchUpInside)
            
            view.addSubview(btn)
            
            btn.snp.makeConstraints { (make) in
                make.width.equalTo(80)
                make.top.bottom.equalTo(0)
                make.trailing.equalToSuperview().offset(80)
            }
            
            textField.snp.makeConstraints { (make) in
                make.leading.top.bottom.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 0))
                make.trailing.equalTo(btn.snp_leadingMargin).offset(-16)
            }
        } else {
            textField.snp.makeConstraints { (make) in
                make.leading.top.bottom.trailing.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12))
            }
        }
        
        
        return view
    }
    
    @objc private func p_textDidChange(_ sender: UITextField) {
        if let closure = searchChangeBlocks[sender] {
            closure(sender.text ?? "")
        }
    }
    
    @objc private func p_searchAction(_ sender: UIButton) {
        let field = sender.superview!.mst_subview(tag: 1) as! UITextField

        if let closure = searchReturnBlocks[field] {
            closure(field)
        }
    }
    
    // 确定按钮
    public class func confirmButton(of title: String, bgColor: UIColor) -> UIButton {
        let btn = UIButton(type: .custom)
        
        btn.frame = CGRect(x: 30, y: 0, width: kScreenWidth - 30*2, height: 50)
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.backgroundColor = bgColor
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.mst_cornerRadius(radius: 5)
        
        return btn
    }
}

// MARK: - Alert Controller
public extension MSTAppUITool {
    
    /// 提示框(有取消)
    /// - Parameters:
    ///   - controller: 展示Controller
    ///   - title: 标题
    ///   - message: 消息
    ///   - cancelActionTitle: 取消按钮标题
    ///   - confirmActionTitle: 确认按钮标题
    ///   - confirmClosure: 确认按钮回调
    class func showAlertController(in controller: UIViewController, title: String, message: String?, cancelActionTitle: String, confirmActionTitle: String, confirmClosure:(() -> Void)?) -> UIAlertController {
        let alertCtrler = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default) { (action) in
            confirmClosure?()
        }
        
        alertCtrler.addAction(cancelAction)
        alertCtrler.addAction(confirmAction)
        
        controller.present(alertCtrler, animated: true, completion: nil)
        
        return alertCtrler
    }
    
    /// 提示框(无取消)
    /// - Parameters:
    ///   - controller: 展示Controller
    ///   - title: 标题
    ///   - message: 消息
    ///   - confirmActionTitle: 确认按钮标题
    ///   - confirmClosure: 确认按钮回调
    class func showAlertControllerWithoutCancel(in controller: UIViewController, title: String, message: String?, confirmActionTitle: String, confirmClosure:(() -> Void)?) -> UIAlertController {
        let alertCtrler = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default) { (action) in
            confirmClosure?()
        }

        alertCtrler.addAction(confirmAction)

        controller.present(alertCtrler, animated: true, completion: nil)

        return alertCtrler
    }
    
}

// MARK: - UITableView
public extension MSTAppUITool {
    class func tableViewCell(in tableView: UITableView, reuseIdentifier: String, cellStyle style: UITableViewCell.CellStyle) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: style, reuseIdentifier: reuseIdentifier)
        }
        
        return cell!
    }
}

// MARK: - UITextFieldDelegate
extension MSTAppUITool: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let btn = textField.superview?.mst_subview(tag: SearchViewButtonTag) {
            UIView.animate(withDuration: 0.25) {
                btn.snp.updateConstraints { (make) in
                    make.trailing.equalToSuperview()
                }
                
                btn.superview!.layoutIfNeeded()
            }
        }
        
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let btn = textField.superview?.mst_subview(tag: SearchViewButtonTag) {
            UIView.animate(withDuration: 0.25) {
                btn.snp.updateConstraints { (make) in
                    make.trailing.equalToSuperview().offset(80)
                }
                
                btn.superview!.layoutIfNeeded()
            }
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let closure = searchReturnBlocks[textField] {
            closure(textField)
        }
        
        return true
    }
}
