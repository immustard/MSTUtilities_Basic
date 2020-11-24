//
//  MSTCycleSlider.swift
//  Volunteerism
//
//  Created by Mustard on 2020/7/16.
//  Copyright © 2020 Mustard. All rights reserved.
//
//  圆形进度条

import UIKit

/// 角度制转换为弧度制
private func CircleDegreeToRadian(_ degree: CGFloat) -> CGFloat {
    return CGFloat.pi*degree/180.0
}

open class MSTCycleSlider: UIView {

    // MARK: - Properties
    /// 起点角度(角度制): -90为`零点`
    public var startAngle: CGFloat = CircleDegreeToRadian(-90) {
        didSet {
            startAngle = CircleDegreeToRadian(startAngle)
            
            setNeedsLayout()
        }
    }
    /// 进度
    private (set) public var progress: CGFloat = 0
    
    /// 动画时长
    public var duration: CFTimeInterval = 1.5
    
    /// 线宽
    public var strokeWidth: CGFloat = 4 {
        didSet {
            _radius = _baseCircleRadius/2 - strokeWidth/2
            setNeedsLayout()
        }
    }
    /// 把手宽
    public var handleWidth: CGFloat = 4 {
        didSet {
            _handleView.frame = CGRect(origin: .zero, size: CGSize(width: handleWidth, height: handleWidth))
            _handleView.mst_cornerRadius(radius: handleWidth/2)
        }
    }
    /// 线颜色
    public var lineColor: UIColor = .white {
        didSet {
            _handleView.layer.borderColor = lineColor.cgColor
            _circleLayer.strokeColor = lineColor.cgColor
        }
    }
    /// 底部线颜色
    public var baseLineColor: UIColor = kHexColor("#F3F4F5") {
        didSet {
            _baseLayer.strokeColor = baseLineColor.cgColor
        }
    }
    /// 把手颜色
    public var handleColor: UIColor = .white {
        didSet {
            if handleHollow {
                _handleView.backgroundColor = handleColor
                _handleView.mst_addBorder(radius: handleWidth/2, lineWidth: 2.5, lineColor: lineColor)
            } else {
                _handleView.backgroundColor = handleColor
                _handleView.mst_addBorder(radius: 0, lineWidth: 0, lineColor: handleColor)
            }
        }
    }
    /// 把手是否空心; 当为空心时: `borderColor`为`lineColor`, `backgroundColor`为`handleColor`
    public var handleHollow: Bool = false {
        didSet {
            if handleHollow {
                _handleView.backgroundColor = handleColor
                _handleView.mst_addBorder(radius: handleWidth/2, lineWidth: 2.5, lineColor: lineColor)
            } else {
                _handleView.backgroundColor = handleColor
                _handleView.mst_addBorder(radius: 0, lineWidth: 0, lineColor: handleColor)
            }
        }
    }

    /// 是否显示标题
    public var isShowTitleLabel = false {
        didSet {
            _titleLabel.isHidden = !isShowTitleLabel
            if isShowTitleLabel {
                _titleLabel.mst_center = CGPoint(x: _centerPoint.x, y: center.y - _titleLabel.mst_height/2)
            } else {
                _subtitleLabel.mst_center = _centerPoint
            }
        }
    }
    /// 标题
    public var titleString = "" {
        didSet {
            _titleLabel.text = titleString
        }
    }
    /// 标题字体
    public var titleFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            _titleLabel.font = titleFont
        }
    }
    /// 标题颜色
    public var titleColor = UIColor.white {
        didSet {
            _titleLabel.textColor = titleColor
        }
    }
    
    /// 是否显示副标题
    public var isShowSubtitleLabel = false {
        didSet {
            _subtitleLabel.isHidden = !isShowSubtitleLabel
            if isShowSubtitleLabel {
                _subtitleLabel.mst_center = CGPoint(x: _centerPoint.x, y: center.y - _subtitleLabel.mst_height/2)
            } else {
                _titleLabel.mst_center = _centerPoint
            }
        }
    }
    /// 副标题
    public var subtitleString = "" {
        didSet {
            _subtitleLabel.text = subtitleString
        }
    }
    /// 副标题字体
    public var subtitleFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            _subtitleLabel.font = subtitleFont
        }
    }
    /// 副标题颜色
    public var subtitleColor = UIColor.white {
        didSet {
            _subtitleLabel.textColor = subtitleColor
        }
    }
    
    private var _baseCircleRadius: CGFloat = 0
    private var _radius: CGFloat = 0
    private var _centerPoint: CGPoint = .zero
    private var _clockwise: Bool = false

    /// 底部圆环
    private var _baseLayer: CAShapeLayer!
    /// 进度圆环
    private var _circleLayer: CAShapeLayer!
    /// 把手
    private var _handleView: UIView!
    /// 标题
    private var _titleLabel: UILabel!
    /// 副标题
    private var _subtitleLabel: UILabel!

    // MARK: - Lazy Load
    
    // MARK: - Initial Methods
    override public init(frame: CGRect) {
        super.init(frame: frame)

        _baseCircleRadius = min(mst_width, mst_height)
        _radius = _baseCircleRadius/2 - strokeWidth/2

        p_initView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Instance Methods
extension MSTCycleSlider {
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        _baseCircleRadius = min(mst_width, mst_height)
        _radius = _baseCircleRadius/2 - strokeWidth/2
        _centerPoint = CGPoint(x: mst_width/2, y: mst_height/2)

        _baseLayer.lineWidth = strokeWidth
        _circleLayer.lineWidth = strokeWidth
        
        _baseLayer.path = p_newBezierPath(endAngle: 2*CGFloat.pi + startAngle).cgPath
        _circleLayer.path = p_newBezierPath(endAngle: progress*2*CGFloat.pi + startAngle).cgPath
        
        _handleView.frame = CGRect(x: 0, y: 0, width: handleWidth, height: handleWidth)
//        _handleView.mst_cornerRadius(radius: handleWidth/2)
        _handleView.center = p_handlePosition()
        if handleHollow {
            _handleView.backgroundColor = handleColor
            _handleView.mst_addBorder(radius: handleWidth/2, lineWidth: 2.5, lineColor: lineColor)
        } else {
            _handleView.backgroundColor = handleColor
            _handleView.mst_addBorder(radius: 0, lineWidth: 0, lineColor: handleColor)
        }
        
        _titleLabel.isHidden = !isShowTitleLabel
        if isShowTitleLabel {
            var margin: CGFloat = 0
            
            _titleLabel.frame = CGRect(x: 0, y: 0, width: _baseCircleRadius, height: 30)
            
            if isShowSubtitleLabel {
                margin = _titleLabel.mst_height*0.5
                _titleLabel.mst_center = CGPoint(x: _centerPoint.x, y: _centerPoint.y - margin+mst_height/20)
            } else {
                _titleLabel.mst_center = CGPoint(x: _centerPoint.x, y: _centerPoint.y)
            }
        }
        
        _subtitleLabel.isHidden = !isShowSubtitleLabel
        if isShowSubtitleLabel {
            var margin: CGFloat = 0
            
            _subtitleLabel.frame = CGRect(x: 0, y: 0, width: _baseCircleRadius, height: 20)
            
            if isShowTitleLabel {
                margin = _subtitleLabel.mst_height*0.5
                _subtitleLabel.mst_center = CGPoint(x: _centerPoint.x, y: _centerPoint.y + margin+mst_height/20)
            } else {
                _subtitleLabel.mst_center = CGPoint(x: _centerPoint.x, y: _centerPoint.y)
            }
        }
        
    }
    
    public func updateProgress(_ progress: CGFloat, clockwise: Bool) {
        self.progress = progress
        _clockwise = clockwise

        if progress < 0 || progress > 1 {
            self.progress = 1
        }

        if !clockwise && progress != 1 {
            self.progress = 1-progress
        }
    }
    
    public func startAnimate() {
        _circleLayer.removeAnimation(forKey: "strokeEndAnimation")
        
        _circleLayer.path = p_newBezierPath(endAngle: progress*CGFloat.pi*3/2).cgPath
        _circleLayer.add(p_circleAnimation(), forKey: "strokeEndAnimation")
        
        _handleView.layer.removeAnimation(forKey: "pointAnimation")
        _handleView.layer.add(p_pointAnimation(), forKey: "pointAnimation")
    }
}

// MARK: - Private Methods
private extension MSTCycleSlider {
    func p_initView() {
        _centerPoint = CGPoint(x: mst_width/2, y: mst_height/2)

        _baseLayer = p_circleLayerBorder(width: strokeWidth, fillColor: .clear, borderColor: baseLineColor)
        layer.addSublayer(_baseLayer)
        
        _circleLayer = p_circleLayerBorder(width: strokeWidth, fillColor: .clear, borderColor: lineColor)
        layer.addSublayer(_circleLayer)
        
        _handleView = UIView()
        _handleView.backgroundColor = handleColor
        addSubview(_handleView)
        
        _titleLabel = UILabel()
        _titleLabel.font = titleFont
        _titleLabel.textColor = titleColor
        _titleLabel.textAlignment = .center
        _titleLabel.isHidden = !isShowTitleLabel
        addSubview(_titleLabel)
        
        _subtitleLabel = UILabel()
        _subtitleLabel.font = subtitleFont
        _subtitleLabel.textColor = subtitleColor
        _subtitleLabel.textAlignment = .center
        _subtitleLabel.isHidden = !isShowSubtitleLabel
        addSubview(_subtitleLabel)
    }
    
    func p_circleLayerBorder(width borderWidth: CGFloat, fillColor: UIColor, borderColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        layer.fillColor = fillColor.cgColor
        layer.strokeColor = borderColor.cgColor
        layer.lineWidth = borderWidth
        layer.lineCap = .round

        return layer
    }
    
    func p_newBezierPath(endAngle: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: _centerPoint, radius: _radius, startAngle: startAngle, endAngle: endAngle, clockwise: _clockwise)
    }
    
    func p_handlePosition() -> CGPoint {
        let currentEndAngle = progress*2*CGFloat.pi + startAngle
        return CGPoint(x: mst_width/2 + _radius*cos(currentEndAngle), y: mst_height/2 + _radius*sin(currentEndAngle))
    }
    
    func p_circleAnimation() -> CAAnimation {
        let ani = CABasicAnimation(keyPath: "strokeEnd")
        
        ani.duration = duration
        ani.fromValue = 0
        ani.toValue = 1
        ani.timingFunction = CAMediaTimingFunction(name: .linear)
        ani.isRemovedOnCompletion = true
        
        return ani
    }
    
    func p_pointAnimation() -> CAAnimation {
        let ani = CAKeyframeAnimation(keyPath: "position")
        
        ani.timingFunction = CAMediaTimingFunction(name: .linear)
        ani.fillMode = .forwards
        ani.calculationMode = .paced
        ani.isRemovedOnCompletion = true
        ani.duration = duration
        
        let path = UIBezierPath(arcCenter: _centerPoint, radius: _radius, startAngle: startAngle, endAngle: progress*2*CGFloat.pi + startAngle, clockwise: _clockwise)
        ani.path = path.cgPath
        
        return ani
    }
}
