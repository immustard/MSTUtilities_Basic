//
//  MSTPageContentView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/19.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

public protocol MSTPageContentViewDelegate: class {
    func contentView(_ contentView: MSTPageContentView, didEndScrollAt index: Int)
    func contentView(_ contentView: MSTPageContentView, scrollingWith sourceIndex: Int, targetIndex: Int, progress: CGFloat)
}

private let _cellID = "MSTPageContentViewCellID"
open class MSTPageContentView: UIView {

    weak var delegate: MSTPageContentViewDelegate?
    
    weak public var eventHandler: MSTPageEventHandleable?
    
    var style: MSTPageStyle
    
    var childViewControllers: [UIViewController]
    
    var currentIndex: Int
    
    private var _startOffsetX: CGFloat = 0
    
    private var _isForbidDelegate: Bool = false
    
    private var _changeClosure: (() -> Void)?
    
    private (set) public lazy var collectionView: MSTGestureCollectionView = {
        let layout = MSTPageCollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = MSTGestureCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
        
        if #available(iOS 10, *) {
            collectionView.isPrefetchingEnabled = false
        }
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: _cellID)
        return collectionView
    }()

    // MARK: - Initial Methods
    public init(frame: CGRect, style: MSTPageStyle, childViewControllers: [UIViewController], currentIndex: Int) {
        self.childViewControllers = childViewControllers
        self.style = style
        self.currentIndex = currentIndex
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.childViewControllers = [UIViewController]()
        self.style = MSTPageStyle()
        self.currentIndex = 0
        super.init(coder: aDecoder)
    }
    
    // MARK: - Instance Methods
    override open func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        let layout = collectionView.collectionViewLayout as! MSTPageCollectionViewFlowLayout
        layout.itemSize = bounds.size
        layout.offset = CGFloat(currentIndex) * bounds.size.width
    }
    
    func setupUI() {
        addSubview(collectionView)
        
        collectionView.backgroundColor = style.contentViewBackgroundColor
        collectionView.isScrollEnabled = style.isContentScrollEnabled
    }
    
    func contentViewDidChanged(_ closure: @escaping (() -> Void)) {
        _changeClosure = closure
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension MSTPageContentView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childViewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _cellID, for: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let childVC = childViewControllers[indexPath.item]
        
        eventHandler = childVC as? MSTPageEventHandleable
        childVC.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVC.view)
        
        return cell
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _isForbidDelegate = false
        _startOffsetX = scrollView.contentOffset.x
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        p_updateUI(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            p_collectionViewDidEndScroll(scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        p_collectionViewDidEndScroll(scrollView)
    }
}

// MARK: - Private Methods
extension MSTPageContentView {
    private func p_collectionViewDidEndScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.mst_width))
        
        delegate?.contentView(self, didEndScrollAt: index)
        
        if index != currentIndex {
            let childVC = childViewControllers[currentIndex]
            (childVC as? MSTPageEventHandleable)?.contentViewDidDisappear?()
        }
        
        currentIndex = index
        
        _changeClosure?()

        eventHandler = childViewControllers[currentIndex] as? MSTPageEventHandleable
        
        eventHandler?.contentViewDidEndScroll?()
    }

    private func p_updateUI(_ scrollView: UIScrollView) {
        guard !_isForbidDelegate else { return }
        
        var progress: CGFloat = 0
        var targetIndex, sourceIndex: Int
        
        progress = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.mst_width) / scrollView.mst_width
        
        guard progress != 0 || !progress.isNaN else { return }
        
        let index = Int(scrollView.contentOffset.x / scrollView.mst_width)
        
        if collectionView.contentOffset.x > _startOffsetX {
            // 左滑
            sourceIndex = index
            targetIndex = index + 1
            guard targetIndex < childViewControllers.count else { return }
        } else {
            sourceIndex = index + 1
            targetIndex = index
            progress = 1 - progress
            guard targetIndex >= 0 else { return }
        }

        if progress > 0.998 {
            progress = 1
        }
        
        delegate?.contentView(self, scrollingWith: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}

// MARK: - MSTPageTitleViewDelegate
extension MSTPageContentView: MSTPageTitleViewDelegate {
    public func titleView(_ titleView: MSTPageTitleView, didSelectAt index: Int) {
        _isForbidDelegate = true
        
        guard currentIndex < childViewControllers.count else { return }
        
        currentIndex = index
        
        let indexPath = IndexPath(item: index, section: 0)
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
}
