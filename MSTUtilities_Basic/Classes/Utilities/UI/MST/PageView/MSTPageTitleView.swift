//
//  MSTPageTitleView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/19.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

@objc public protocol MSTPageTitleViewDelegate: class {
    
    /// PageView的事件回调处理者
    @objc optional var eventHandler: MSTPageEventHandleable? { get }
    
    func titleView(_ titleView: MSTPageTitleView, didSelectAt index: Int)
}

/// PageView的事件回调，如果有需要，请让对应的childViewController遵守这个协议
@objc public protocol MSTPageEventHandleable: class {
    
    /// 重复点击pageTitleView后调用
    @objc optional func titleViewDidSelectSameTitle()
    
    /// pageContentView的上一页消失的时候，上一页对应的controller调用
    @objc optional func contentViewDidDisappear()
    
    /// pageContentView滚动停止的时候，当前页对应的controller调用
    @objc optional func contentViewDidEndScroll()
    
}

public typealias MSTTitleClickHandler = (MSTPageTitleView, Int) -> ()

private let TitleBackgroundViewTag = 1120

open class MSTPageTitleView: UIView {

    // MARK: - Properties
    weak var delegate: MSTPageTitleViewDelegate?
    
    var clickHandler: MSTTitleClickHandler?

    var currentIndex: Int
    
    private (set) public lazy var titleLabels: [UILabel] = [UILabel]()
    
    private var _titleBgViews: [UIView] = []
    
    var style: MSTPageStyle
    
    var titles: [String]
    
    open override var frame: CGRect {
        didSet {
            p_setupSplitLineLayout()
        }
    }
    
    // MARK: - Lazy Load
    private lazy var _normalRGB: mstColorRGB = self.style.titleColor.mst_getRGB()
    private lazy var _selectRGB: mstColorRGB = self.style.titleSelectedColor.mst_getRGB()
    private lazy var _deltaRGB: mstColorRGB = {
        let deltaR = self._selectRGB.red - self._normalRGB.red
        let deltaG = self._selectRGB.green - self._normalRGB.green
        let deltaB = self._selectRGB.blue - self._normalRGB.blue

        return (deltaR, deltaG, deltaB, 1)
    }()
    
    private lazy var _scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false

        return scrollView
    }()
    
    private lazy var _bottomLine: UIView = {
        let bottomLine = UIView()

        bottomLine.backgroundColor = self.style.bottomLineColor
        bottomLine.layer.cornerRadius = self.style.bottomLineRadius

        return bottomLine
    }()
    
    private lazy var _splitLine: UIView = {
        let splitLine = UIView()
        
        splitLine.backgroundColor = self.style.splitLineColor
        
        return splitLine
    }()
    
    private (set) public lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.backgroundColor = self.style.coverViewBgColor
        coverView.alpha = self.style.coverViewAlpha
        return coverView
    }()
    
    // MARK: - Initial Methods
    public init(frame: CGRect, style: MSTPageStyle, titles: [String], currentIndex: Int) {
        self.style = style
        self.titles = titles
        self.currentIndex = currentIndex
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.style = MSTPageStyle()
        self.titles = [String]()
        self.currentIndex = 0
        super.init(coder: aDecoder)
    }
    
    // MARK: - Instance Methods
    /// 通过代码实现点了某个位置的 titleView
    /// - Parameter index: 需要点击的 titleView 的下标
    func selectedTitle(at index: Int) {
        if index > titles.count || index < 0 {
            print("MSTPageTitleView -- selectedTitle: 数组越界了, index 的值超出有效范围")
        }

        clickHandler?(self, index)

        guard index != currentIndex else {
            delegate?.eventHandler??.titleViewDidSelectSameTitle?()
            return
        }
        
        let sourceLabel = titleLabels[currentIndex]
        let targetLabel = titleLabels[index]

        sourceLabel.textColor = style.titleColor
        targetLabel.textColor = style.titleSelectedColor

        delegate?.eventHandler??.contentViewDidDisappear?()

        currentIndex = index
        
        delegate?.titleView(self, didSelectAt: currentIndex)

        p_adjustLabelPosition(targetLabel)

        if style.isTitleScaleEnabled {
            UIView.animate(withDuration: 0.25) {
                sourceLabel.transform = CGAffineTransform.identity
                targetLabel.transform = CGAffineTransform(scaleX: self.style.titleMaximumScaleFactor, y: self.style.titleMaximumScaleFactor)
            }
        }
        
        if style.isShowBottomLine {
            UIView.animate(withDuration: 0.25) {
                self._bottomLine.frame.size.width = self.style.bottomLineWidth > 0 ? self.style.bottomLineWidth : targetLabel.frame.width
                self._bottomLine.mst_centerX = targetLabel.mst_centerX
            }
        }
        
        if style.isShowCoverView {
            if style.isCoverViewSlide {
                UIView.animate(withDuration: 0.25) {
                    self.coverView.mst_width = (targetLabel.mst_width - self.style.coverMargin*2)
                    //                self.coverView.mst_width = self.style.isTitleViewScrollEnabled ? (targetLabel.mst_width + self.style.coverMargin*2) : targetLabel.mst_width
                    self.coverView.mst_centerX = targetLabel.mst_centerX
                }
            } else {
                self.coverView.mst_width = (targetLabel.mst_width - self.style.coverMargin*2)
                self.coverView.mst_centerX = targetLabel.mst_centerX
            }
        }
        
        sourceLabel.backgroundColor = .clear
        targetLabel.backgroundColor = style.titleViewSelectedColor
    }
    
    func setupUI() {
        addSubview(_scrollView)
        
        _scrollView.backgroundColor = style.titleViewBackgroundColor
        
        p_setupTitleLabels()
        p_setupBottomLine()
        p_setupSplitLine()
        p_setupCoverView()
        if style.isShowTitleBgView {
            p_setupTitleBgView()
        }
    }
    
    private func p_setupTitleBgView() {
        for (i, _) in titles.enumerated() {
            let view = UIView()
            
            view.tag = TitleBackgroundViewTag + i
            view.backgroundColor = style.titleBgViewColor
            
            if style.isTitleBgViewCircle {
                view.mst_cornerRadius(radius: style.titleBgViewHeight/2)
            }
            
            _scrollView.insertSubview(view, at: 0)
            
            _titleBgViews.append(view)
        }
    }
    
    private func p_setupTitleLabels() {
        for (i, title) in titles.enumerated() {
            let label = UILabel()
            
            label.tag = i
            label.text = title
            label.textColor = i == currentIndex ? style.titleSelectedColor : style.titleColor
//            label.backgroundColor = i == currentIndex ? style.titleViewSelectedColor : UIColor.clear;
            label.textAlignment = .center
            label.font = style.titleFont
            label.mst_addTapGesture(target: self, action: #selector(p_tappedTitleLabel(_:)))
            label.isUserInteractionEnabled = true
            
            _scrollView.addSubview(label)
    
            titleLabels.append(label)
        }
    }
    
    private func p_setupBottomLine() {
        guard style.isShowBottomLine else { return }
        
        _scrollView.addSubview(_bottomLine)
    }
    
    private func p_setupSplitLine() {
        guard style.isShowSplitLine else { return }
                
        addSubview(_splitLine)
    }
    
    
    private func p_setupCoverView() {
        
        guard style.isShowCoverView else { return }
        
        _scrollView.insertSubview(coverView, at: 0)
        
        coverView.layer.cornerRadius = style.coverViewRadius
        coverView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @objc private func p_tappedTitleLabel(_ tapGes: UITapGestureRecognizer) {
        guard let index = tapGes.view?.tag else { return }
        
        selectedTitle(at: index)
    }
    
    private func p_adjustLabelPosition(_ targetLabel: UILabel) {
        guard style.isTitleViewScrollEnabled, _scrollView.contentSize.width > _scrollView.frame.width else { return }
        
        var offsetX = max((targetLabel.mst_centerX - frame.width*0.5), 0)
        
        offsetX = min(offsetX, (_scrollView.contentSize.width - _scrollView.frame.width))

        _scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    // MARK: - Layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        _scrollView.frame = self.bounds
        
        p_setupLabelsLayout()
        p_setupTitleBgViewLayout()
        p_setupCoverViewLayout()
        p_setupBottomLineLayout()
    }
    
    private func p_setupTitleBgViewLayout() {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        let height: CGFloat = style.titleBgViewHeight
        
        for (i, view) in _titleBgViews.enumerated() {
            if let label = titleLabels[safe: i] {
                width = label.mst_width - 2*style.titleBgViewHorizantalInset

                x = label.mst_left + style.titleBgViewHorizantalInset
                y = (frame.height - style.titleBgViewHeight)/2
            }
            
            view.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    private func p_setupLabelsLayout() {
        var x: CGFloat = 0
        let y: CGFloat = 0
        var width: CGFloat = 0
        let height: CGFloat = frame.height
        
        let count = titleLabels.count
        for (i, titleLabel) in titleLabels.enumerated() {
            if style.titleItemWidth > 0 {
                width = style.titleItemWidth
                x = width*CGFloat(i)
            } else {
                if style.isTitleViewScrollEnabled {
                    width = titles[i].mst_textWidth(maxHeight: 0, font: style.titleFont)+2 + 2*style.titlePadding
                    x = (i == 0) ? style.titleMargin*0.5 : (titleLabels[i-1].mst_right + style.titleMargin)
                } else {
                    width = frame.width / CGFloat(count)
                    x = width*CGFloat(i)
                }
            }
            titleLabel.transform = CGAffineTransform.identity
            titleLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        if style.isTitleScaleEnabled {
            titleLabels[currentIndex].transform = CGAffineTransform(scaleX: style.titleMaximumScaleFactor, y: style.titleMaximumScaleFactor)
        }
        
//        if style.isTitleScaleEnabled {
            guard let titleLabel = titleLabels.last else { return }
            _scrollView.contentSize.width = titleLabel.mst_right + style.titleMargin*0.5
//        }
    }
    
    private func p_setupCoverViewLayout() {
        guard currentIndex < titleLabels.count else { return }
        let label = titleLabels[currentIndex]
        var width = label.mst_width
        let height = style.coverViewHeight
        
//        if style.isTitleViewScrollEnabled {
            width -= 2*style.coverMargin
//        }
        coverView.frame.size = CGSize(width: width, height: height)
        coverView.center = label.center
    }

    private func p_setupBottomLineLayout() {
        guard currentIndex < titleLabels.count else { return }
        let label = titleLabels[currentIndex]

        _bottomLine.mst_width = style.bottomLineWidth > 0 ? style.bottomLineWidth : label.mst_width
        _bottomLine.mst_height = style.bottomLineHeight
        _bottomLine.mst_centerX = label.mst_centerX
        
        if style.isShowSplitLine {
            _bottomLine.mst_top = frame.height - _bottomLine.mst_height - style.splitLineHeight
        } else {
            _bottomLine.mst_top = frame.height - _bottomLine.mst_height
        }
    }
    
    private func p_setupSplitLineLayout() {
        let frame = CGRect(x: 0, y: self.mst_height - style.splitLineHeight, width: self.mst_width, height: style.splitLineHeight)
        
        _splitLine.frame = frame
    }
}

extension MSTPageTitleView: MSTPageContentViewDelegate {
    public func contentView(_ contentView: MSTPageContentView, didEndScrollAt index: Int) {
        let sourceLabel = titleLabels[currentIndex]
        let targetLabel = titleLabels[index]
        
        sourceLabel.backgroundColor = .clear
        targetLabel.backgroundColor = style.titleViewSelectedColor
        
        currentIndex = index
        
        p_adjustLabelPosition(targetLabel)
        
        p_fixUI(targetLabel)
    }
    
    public func contentView(_ contentView: MSTPageContentView, scrollingWith sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        if sourceIndex >= titleLabels.count || sourceIndex < 0 {
            return
        }
        if targetIndex >= titleLabels.count || targetIndex < 0 {
            return
        }

        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]
        sourceLabel.textColor = UIColor(r: _selectRGB.red - progress*_deltaRGB.red, g: _selectRGB.green - progress*_deltaRGB.green, b: _selectRGB.blue - progress*_deltaRGB.blue)
        targetLabel.textColor = UIColor(r: _normalRGB.red + progress*_deltaRGB.red, g: _normalRGB.green + progress*_deltaRGB.green, b: _normalRGB.blue + progress*_deltaRGB.blue)
        
        if style.isTitleScaleEnabled {
            let deltaScale = style.titleMaximumScaleFactor - 1
            sourceLabel.transform = CGAffineTransform(scaleX: style.titleMaximumScaleFactor - progress * deltaScale, y: style.titleMaximumScaleFactor - progress * deltaScale)
            targetLabel.transform = CGAffineTransform(scaleX: 1.0 + progress * deltaScale, y: 1.0 + progress * deltaScale)
        }
        
        if style.isShowBottomLine {
            if style.bottomLineWidth <= 0 {
                let deltaWidth = targetLabel.frame.width - sourceLabel.frame.width
                _bottomLine.frame.size.width = sourceLabel.frame.width + progress * deltaWidth
            }
            let deltaCenterX = targetLabel.center.x - sourceLabel.center.x
            _bottomLine.center.x = sourceLabel.center.x + progress * deltaCenterX
        }
        
        if style.isShowCoverView && style.isCoverViewSlide {
            let deltaWidth = targetLabel.frame.width - sourceLabel.frame.width
            coverView.mst_width = sourceLabel.frame.width - 2 * style.coverMargin + deltaWidth * progress
//            coverView.frame.size.width = style.isTitleViewScrollEnabled ? (sourceLabel.frame.width + 2 * style.coverMargin + deltaWidth * progress) : (sourceLabel.frame.width + deltaWidth * progress)
            let deltaCenterX = targetLabel.center.x - sourceLabel.center.x
            coverView.center.x = sourceLabel.center.x + deltaCenterX * progress
        }
    }
    
    private func p_fixUI(_ targetLabel: UILabel) {
        UIView.animate(withDuration: 0.05) {
            targetLabel.textColor = self.style.titleSelectedColor
            
            if self.style.isTitleScaleEnabled {
                targetLabel.transform = CGAffineTransform(scaleX: self.style.titleMaximumScaleFactor, y: self.style.titleMaximumScaleFactor)
            }
            
            if self.style.isShowBottomLine {
                if self.style.bottomLineWidth <= 0 {
                    self._bottomLine.mst_width = targetLabel.mst_width
                }
                self._bottomLine.mst_centerX = targetLabel.mst_centerX
            }
            
            if self.style.isShowCoverView && self.style.isCoverViewSlide {
                self.coverView.mst_width = targetLabel.mst_width - 2*self.style.coverMargin

//                self.coverView.mst_width = self.style.isTitleViewScrollEnabled ? (targetLabel.mst_width + 2*self.style.coverMargin) : targetLabel.mst_width
                self.coverView.mst_centerX = targetLabel.mst_centerX
            }
        }
        
        if style.isShowCoverView && !style.isCoverViewSlide {
            self.coverView.mst_width = targetLabel.mst_width - 2*self.style.coverMargin
            self.coverView.mst_centerX = targetLabel.mst_centerX
        }

    }
}
