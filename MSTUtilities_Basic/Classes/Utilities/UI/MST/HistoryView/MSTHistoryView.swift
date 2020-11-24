//
//  MSTHistoryView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/29.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

private let CellID = "MSTHistoryViewCellID"

@objc public protocol MSTHistoryViewDelegate {
    /// 历史列表已经选择
    @objc optional func historyView(_ view: MSTHistoryView, didselectedItemsAt indexSet: Set<Int>)
    
    /// 已经选择最大数量, 当最大数量为0时不回调
    @objc optional func historyViewDidSelectedMaxCount(_ view: MSTHistoryView, didselectedItemsAt indexSet: Set<Int>)
}

open class MSTHistoryView: UICollectionView {

    public static var layout: MSTCollectionViewLeftAlignedLayout = {
        let layout = MSTCollectionViewLeftAlignedLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        return layout
    }()
    
    // MARK: - Properties
    /// 数据源
    public var itemsArray: [String] = [] {
        didSet {
            self.reloadData()
            layoutIfNeeded()
        }
    }
    
    /// 数据源图片, 统一一个
    public var imageString: String = "" {
        didSet {
            self.reloadData()
        }
    }

    /// 高度
    public var viewHeight: CGFloat = 0
    
    /// 最大选择数 (当0时, 直接返回)
    public var maxSelectCount: Int = 0
    
    /// 选择颜色
    public var selectedColor: UIColor = kHexColor("#D5EBFA") {
        didSet {
            reloadData()
        }
    }
    
    /// 正常颜色
    public var normalColor: UIColor = kHexColor("#F6F6F6") {
        didSet {
            reloadData()
        }
    }
    
    /// 文字颜色
    public var titleColor: UIColor = kHexColor("#333333") {
        didSet {
            reloadData()
        }
    }
    
    /// 代理
    public var mDelegate: MSTHistoryViewDelegate?
    
    // MARK: - Private Properties
    private var _selectedSet: Set<Int> = []
    
    // MARK: - Initial Methods
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        self.register(MSTHistoryViewCell.self, forCellWithReuseIdentifier: CellID)
        self.dataSource = self
        self.delegate = self

        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Instance Methods
    override public func layoutSubviews() {
        super.layoutSubviews()
        
//        viewHeight = collectionViewLayout.collectionViewContentSize.height
//        mst_height = viewHeight
    }
    
    public func resetSelectedArray() {
        _selectedSet.removeAll()
        reloadData()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension MSTHistoryView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath) as! MSTHistoryViewCell

        cell.button.setTitle(itemsArray[indexPath.item], for: .normal)
        cell.button.setTitleColor(titleColor, for: .normal)
        cell.button.setImage(UIImage(named: imageString), for: .normal)
        cell.contentView.backgroundColor = normalColor
        
        if kStrIsEmpty(imageString) {
            cell.button.mst_layoutButton(style: .left, spaceBetweenImageAndTitle: 0)
        } else {
            cell.button.mst_layoutButton(style: .left, spaceBetweenImageAndTitle: 6)
        }

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if maxSelectCount <= 0 {
            mDelegate?.historyView?(self, didselectedItemsAt: [indexPath.item])
        } else {
            if let cell = self.cellForItem(at: indexPath) as? MSTHistoryViewCell {
                if _selectedSet.contains(indexPath.item) { // 取消选中
                    cell.contentView.backgroundColor = normalColor

                    _selectedSet.remove(indexPath.item)
                    mDelegate?.historyView?(self, didselectedItemsAt: _selectedSet)
                } else { // 选中
                    if _selectedSet.count == maxSelectCount {
                        mDelegate?.historyViewDidSelectedMaxCount?(self, didselectedItemsAt: _selectedSet)
                    } else {
                        cell.contentView.backgroundColor = selectedColor
                        
                        _selectedSet.insert(indexPath.item)
                        mDelegate?.historyView?(self, didselectedItemsAt: _selectedSet)
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewFlowLayout
extension MSTHistoryView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 0.01, height: 50)
    }
}
