//
//  TitleRollView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/12/9.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

@objc public protocol TitleRollViewDelegate {
    /// 点击滚动文字回调
    /// - Parameters:
    ///   - rollView: TitleRollView
    ///   - index: 选中文字的 index
    @objc optional func titleRollView(_ rollView: TitleRollView, didSelectItemAt index: Int)
    
    /// 文字滚动的回调
    /// - Parameters:
    ///   - rollView: TitleRollView
    ///   - index: 滚动到的 index
    @objc optional func titleRollView(_ rollView: TitleRollView, didScrollToIndex index: Int)
}

fileprivate let CellID = "MSTTitleRollViewCellID"

open class TitleRollView: UIView {

    // MARK: - Properties
    /// 自动滚动间隔时间
    public var autoScrollTimeInterval: TimeInterval = 2 {
        didSet {
            p_invalidateTimer()
            
            if self.isAutoScroll {
                p_setupTimer()
            }
        }
    }
    
    /// 是否无限循环
    public var isInfiniteLoop: Bool = true
    
    /// 是否自动滚动
    public var isAutoScroll: Bool = true {
        didSet {
            p_invalidateTimer()
            
            if self.isAutoScroll {
                p_setupTimer()
            }
        }
    }
    
    /// 是否允许用户拖动
    public var isDragEnabled: Bool = true {
        didSet {
            _mainCollectionView.isScrollEnabled = self.isDragEnabled
        }
    }
    
    /// 每次展示个数
    public var num: Int = 4
    
    /// 文字滚动方向
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            _flowLayout.scrollDirection = scrollDirection
        }
    }
    
    /// 代理
    public var delegate: TitleRollViewDelegate?
    
    public var titlesArray: [String] = [] {
        didSet {
            if self.titlesArray.count <= num {
                num = self.titlesArray.count
                
                num = max(1, num)
            }
            
            _totalItemsCount = self.isInfiniteLoop ? self.titlesArray.count * 100 : self.titlesArray.count
            
            if self.titlesArray.count <= 1 {
                if self.isDragEnabled {
                    self._mainCollectionView.isScrollEnabled = true
                }
            } else {
                self._mainCollectionView.isScrollEnabled = false
            }
            
            self._mainCollectionView.reloadData()
            
            if self.isAutoScroll {
                self.p_setupTimer()
            }
        }
    }
    public var typesGroup: [String] = [] {
        didSet {
            _imgStrArray.removeAll()
            
            for type in typesGroup {
                var imgS = ""
                if type.mst_intValue == 1 {
                    imgS = "index_gg"
                } else {
                    imgS = "index_zx"
                }
                
                _imgStrArray.append(imgS)
            }
            
            _mainCollectionView.reloadData()
            
            if self.isAutoScroll {
                self.p_setupTimer()
            }
        }
    }
    
    private var _imgStrArray: [String] = []
    
    private var _totalItemsCount: Int = 0
    
    private var _timer: Timer?
        
    // MARK: - Lazy Load
    private lazy var _flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        
        return layout
    }()
    
    private lazy var _mainCollectionView: UICollectionView = {
        let view = UICollectionView(frame: self.bounds, collectionViewLayout: self._flowLayout)
        view.backgroundColor = .clear
        view.isPagingEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.scrollsToTop = false
        view.isScrollEnabled = self.isDragEnabled
        view.register(TitleRollCollectionCell.self, forCellWithReuseIdentifier: CellID)
        
        if #available(iOS 11, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        
        return view
    }()
    
    // MARK: - Initial Methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        p_createUI()
    }
    
    deinit {
        p_invalidateTimer()
        
        _mainCollectionView.dataSource = nil
        _mainCollectionView.delegate = nil
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Instance Methods
extension TitleRollView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        _flowLayout.itemSize = CGSize(width: mst_width, height: mst_height/CGFloat(num))
        _mainCollectionView.frame = bounds
        
        if _mainCollectionView.contentOffset.x == 0 && _totalItemsCount > 0 {
            var targetIdx = 0
            if isInfiniteLoop {
                targetIdx = Int(Double(_totalItemsCount) * 0.5 + 1)
            }
            
            _mainCollectionView.scrollToItem(at: IndexPath(item: targetIdx, section: 0), at: .init(), animated: false)
        }
    }
}

// MARK: - Private Methods
private extension TitleRollView {
    func p_createUI() {
        addSubview(_mainCollectionView)
    }
    
    func p_pageControlIndex(of index: Int) -> Int {
        return index % titlesArray.count
    }
    
    func p_currentIndex() -> Int {
        guard _mainCollectionView.mst_size != .zero else {
            return 0
        }
        
        var idx = 0
        
        if _flowLayout.scrollDirection == .horizontal {
            idx = Int((_mainCollectionView.contentOffset.x + _flowLayout.itemSize.width*0.5) / _flowLayout.itemSize.width)
        } else {
            idx = Int((_mainCollectionView.contentOffset.y + _flowLayout.itemSize.height*0.5) / _flowLayout.itemSize.height)
        }
        
        return max(0, idx)
    }
    
    func p_setupTimer() {
        if _timer != nil {
            p_invalidateTimer()
        }
        
        _timer = Timer.scheduledTimer(withTimeInterval: autoScrollTimeInterval, repeats: true, block: { (timer) in
            guard self._totalItemsCount != 0 else { return }
            
            let currentIdx = self.p_currentIndex()
            let targetIdx = currentIdx + self.num
            
            self.p_scrollToIndex(targetIdx)
        })
        
        RunLoop.main.add(_timer!, forMode: .common)
    }
    
    func p_invalidateTimer() {
        _timer?.invalidate()
        
        _timer = nil
    }
    
    func p_scrollToIndex(_ idx: Int) {
        guard idx < _totalItemsCount else {
            if isInfiniteLoop {
                var targetIdx = idx

                targetIdx = Int(Double(_totalItemsCount) * 0.5 + 1)
                _mainCollectionView.scrollToItem(at: IndexPath(item: targetIdx, section: 0), at: .init(), animated: false)
            }
            return
        }
        
        _mainCollectionView.scrollToItem(at: IndexPath(item: idx, section: 0), at: .init(), animated: true)
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension TitleRollView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _totalItemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath) as! TitleRollCollectionCell
        
        let itemIdx = p_pageControlIndex(of: indexPath.item)
        
        if !kArrIsEmpty(titlesArray) && itemIdx < titlesArray.count {
            cell.titleStr = titlesArray[itemIdx]
        }
        
        if !kArrIsEmpty(_imgStrArray) && itemIdx < _imgStrArray.count {
            cell.imgStr = _imgStrArray[itemIdx]
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemIdx = p_pageControlIndex(of: indexPath.item)
        
        delegate?.titleRollView?(self, didSelectItemAt: itemIdx)
    }
    
    // MARK: - UISrollViewDelegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScroll {
            p_invalidateTimer()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoScroll {
            p_setupTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(_mainCollectionView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard !kArrIsEmpty(titlesArray) else { return }
        
        let currentItem = p_currentIndex()
        let itemIdx = p_pageControlIndex(of: currentItem)
        
        delegate?.titleRollView?(self, didScrollToIndex: itemIdx)
    }
}
