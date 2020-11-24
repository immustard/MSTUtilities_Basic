//
//  MSTScrollTitleView.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/7/8.
//

import UIKit

public protocol MSTScrollTitleViewDelegate: class {
    func scrollTitleViewDidScroll(to idx: Int)
}

private let CellID = "MSTScrollTitleViewCellID"

// 如果 title 显示不出来, 设置 controller 的 `automaticallyAdjustScrollViewInsets` 为 `false`
open class MSTScrollTitleView: UIView {

    // MARK: - Properties
    public weak var contentView: UIScrollView? {
        didSet {
            contentView?.delegate = self
        }
    }
    
    public var indicatorColor: UIColor = UIColor.mst_color(light: .black, dark: .white) {
        didSet {
            _indicatorLine.backgroundColor = indicatorColor
        }
    }
    
    public var indicatorWidth: CGFloat = 20
    
    public var titleColor: UIColor = UIColor.mst_color(light: kHexColor("333"), dark: kHexColor("CCC")) {
        didSet {
            _collectView.reloadData()
        }
    }
    
    public var bgColor: UIColor = UIColor.mst_color(light: .white, dark: .black) {
        didSet {
            self.backgroundColor = bgColor
            _collectView.backgroundColor = bgColor
        }
    }
    
    public weak var delegate: MSTScrollTitleViewDelegate?
    
    private var _padding: CGFloat = 20
    
    private var _titles: [String] = []
    
    private var _currentIdx: Int = 0
    
    private var _itemWidth: CGFloat = 0

    // MARK: - Lazy Load
    private lazy var _collectView: UICollectionView = {
        let view = UICollectionView(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)), collectionViewLayout: self._layout)
        
        view.backgroundColor = self.bgColor
        view.dataSource = self
        view.delegate = self
        
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellID)
        
        return view
    }()
    
    private lazy var _layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        return layout
    }()
    
    private lazy var _indicatorLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 2))
        
        view.backgroundColor = self.indicatorColor
        view.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        
        return view
    }()

    // MARK: - Initial Methods
    public convenience init(titles: [String]) {
        self.init(frame: .zero)
        
        _titles = titles

        p_initView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        p_initView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        contentView?.delegate = nil
        _indicatorLine.removeObserver(self, forKeyPath: "frame")
    }
    
    // MARK: - Instance Methods
    public func setSelectIndex(_ idx: Int, animated: Bool) {
        guard idx != _currentIdx else { return }
        
        if let nowCell = _collectView.cellForItem(at: IndexPath(item: idx, section: 0)) {
            (nowCell.viewWithTag(1120) as! UILabel).textColor = indicatorColor
        }
        if let oldCell = _collectView.cellForItem(at: IndexPath(item: _currentIdx, section: 0)) {
            (oldCell.viewWithTag(1120) as! UILabel).textColor = titleColor
        }
        
        _currentIdx = idx
        let duration: TimeInterval = animated ? 0.26 : 0
        
        UIView.animate(withDuration: duration, animations: {
            self._indicatorLine.mst_left = self._itemWidth*CGFloat(idx) + (self._itemWidth - self.indicatorWidth)/2.0 + self._padding
        }, completion: nil)
        
        if contentView != nil {
            contentView!.setContentOffset(CGPoint(x: contentView!.mst_width*CGFloat(idx), y: 0), animated: false)
        }
        
        delegate?.scrollTitleViewDidScroll(to: idx)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        _collectView.frame = CGRect(x: 20, y: 0, width: mst_width - _padding*2, height: mst_height)
        _indicatorLine.mst_top = mst_height - _indicatorLine.mst_height
        _itemWidth = _titles.count == 0 ? 0 : (mst_width - _padding*2)/CGFloat(_titles.count)
        _layout.itemSize = CGSize(width: _itemWidth, height: mst_height)
        
        _indicatorLine.mst_width = indicatorWidth
        _indicatorLine.mst_left = (_itemWidth - indicatorWidth)/2.0
    }
}

// MARK: - Private Methods
private extension MSTScrollTitleView {
    func p_initView() {
        self.backgroundColor = bgColor
        
        addSubview(_collectView)
        addSubview(_indicatorLine)
    }
    
}

// MARK: - UICollectionViewDataSource & Delegate
extension MSTScrollTitleView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _titles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath)
        
        var label = cell.contentView.viewWithTag(1120) as? UILabel
        if label == nil {
            label = UILabel()
            label!.font = .systemFont(ofSize: 15, weight: .bold)
            label!.tag = 1120
            
            cell.contentView.addSubview(label!)
            label!.snp.makeConstraints { (maker) in
                maker.top.leading.bottom.trailing.equalToSuperview()
            }
        }
        
        label!.text = _titles[indexPath.item]
        label!.textColor = (indexPath.item == _currentIdx) ? indicatorColor : titleColor
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setSelectIndex(indexPath.item, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension MSTScrollTitleView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if contentView != nil {
            let offX = contentView!.contentOffset.x * _itemWidth / contentView!.mst_width
            
            if contentView!.isDragging {
                _indicatorLine.mst_left = offX + (_itemWidth - indicatorWidth)/2.0
            } else if contentView!.isDecelerating {
                UIView.animate(withDuration: 0.26) {
                    self._indicatorLine.mst_left = offX + (self._itemWidth - self.indicatorWidth)/2.0
                }
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if contentView != nil {
            _currentIdx = Int(contentView!.contentOffset.x/(contentView!.mst_width + 0.5) + _padding)
            
            delegate?.scrollTitleViewDidScroll(to: Int(CGFloat(_currentIdx) - _padding))
        }
    }
}

// MARK: - 监听UIScrollView的contentOffset属性
extension MSTScrollTitleView {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard "frame" == keyPath else { return }
        
        let leftX: CGFloat = _indicatorLine.mst_left - (_itemWidth - indicatorWidth)/2.0
        
        let midIdx = _itemWidth == 0 ? -2 : Int(leftX/_itemWidth)
        let leftIdx = Int(midIdx + 1)
        let rightIdx = Int(midIdx - 1)
        
        if let midCell = _collectView.cellForItem(at: IndexPath(item: midIdx, section: 0)) {
            (midCell.contentView.viewWithTag(1120) as! UILabel).textColor = indicatorColor
        }
        
        if let leftCell = _collectView.cellForItem(at: IndexPath(item: leftIdx, section: 0)) {
            (leftCell.contentView.viewWithTag(1120) as! UILabel).textColor = titleColor
        }
        
        if let rightCell = _collectView.cellForItem(at: IndexPath(item: rightIdx, section: 0)) {
            (rightCell.contentView.viewWithTag(1120) as! UILabel).textColor = titleColor
        }
        
    }
}
