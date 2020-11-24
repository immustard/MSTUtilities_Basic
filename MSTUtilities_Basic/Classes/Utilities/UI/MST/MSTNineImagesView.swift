//
//  MSTNineImagesView.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/12/19.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit
import SDWebImage

public enum MSTNineImagesViewStyle {
    case edit   // 编辑状态
    
    case editFull // 编辑状态(展示所有占位图)

    case display    // 展示状态
}

public enum MSTNineImagesViewDisplayType {
    case equal
    
    case ratio_4_3
    
    case ratio_16_9
}

@objc public protocol MSTNineImagesViewDelegate {
    @objc optional func nineImagesView(_ imagesView: MSTNineImagesView, didselectedAtIndex index: Int, imageViews: [UIImageView])
    
    /// 删除图片 (只有在编辑状态下回调)
    @objc optional func nineImagesView(_ imagesView: MSTNineImagesView, shouldDeleteAtIndex index: Int)
    
    /// 添加图片 (只有在编辑状态下回调)
    @objc optional func nineImagesViewShouldAddImage(_ imagesView: MSTNineImagesView, idx: Int)
}

let _padding: CGFloat = 5

open class MSTNineImagesView: UIView {
    
    // MARK: - Properties
    /// 代理
    public var delegate: MSTNineImagesViewDelegate?
    /// 最大图片数量, 仅在`edit`模式下可用
    public var maxCount = 9
    /// 添加占位图(当`style`为`editFull`时, 取全部; `edit`时, 取`first`)
    public var addPlaceholder: [String] = [] {
        didSet {
            p_updateImage()
        }
    }
    
    // MARK: - Private Properties
    private var _style: MSTNineImagesViewStyle = .display
    
    private var _type: MSTNineImagesViewDisplayType = .equal

    private var _isZoom: Bool = true
    
    private var _images: [UIImage]?
    
    private var _imageViews: [UIImageView] = []
    
    private var _fileIDs: [String]?
}

public extension MSTNineImagesView {
    // MARK: - Class Methods
    /// 获取高度
    /// - Parameters:
    ///   - count: 媒体个数
    ///   - width: `MSTNineImagesView`的整体宽度
    ///   - displayType: 显示类型
    ///   - isZoom: 是否根据个数适配
    /// - Returns: 高度
    class func viewHeight(count: Int, viewWidth width: CGFloat, displayType: MSTNineImagesViewDisplayType, isZoom: Bool = true) -> CGFloat {
        let size = p_imageViewSize(count: count, viewWidth: width, displayType: displayType, isZoom: isZoom)
        var height: CGFloat = 0
        
        if isZoom {
            switch count {
            case 0,1,2:
                height = size.height
            case 4:
                height = size.height*2 + _padding
            default:
                let rows = (count - 1)/3 + 1
                
                height = size.height * CGFloat(rows) + _padding*(CGFloat(rows) - 1)
            }
        } else {
            let rows = (count - 1)/3 + 1
            
            height = size.height * CGFloat(rows) + _padding*(CGFloat(rows) - 1)
        }
        return height
    }
    
    private class func p_imageViewSize(count: Int, viewWidth: CGFloat, displayType: MSTNineImagesViewDisplayType, isZoom: Bool = true) -> CGSize {
        let ratio = p_ratio(displayType)
        var width: CGFloat = 0
        
        if isZoom {
            switch count {
            case 0:
                break
            case 1:
                width = viewWidth*2/3
            case 2:
                width = (viewWidth - _padding)/2
            case 4:
                width = (viewWidth*4/5 - _padding)/2
            default:
                width = (viewWidth - 2*_padding)/3
            }
        } else{
            width = (viewWidth - 2*_padding)/3
        }
        
        return CGSize(width: width, height: width*ratio)
    }
    
    private class func p_ratio(_ type: MSTNineImagesViewDisplayType) -> CGFloat {
        switch type {
        case .equal:
            return 1
        case .ratio_4_3:
            return 3.0/4.0
        case .ratio_16_9:
            return 9.0/16.0
        }
    }
}

// MARK: - Initial Methods
public extension MSTNineImagesView {
    convenience init(frame: CGRect, style: MSTNineImagesViewStyle, displayType: MSTNineImagesViewDisplayType, images: [UIImage]?, isZoom: Bool = true) {
        self.init(frame: frame)
        
        _style = style
        _type = displayType
        _images = images
        _isZoom = isZoom
        
        p_initView()
    }
}

// MARK: - Instance Methods
public extension MSTNineImagesView {
    func updateImages(_ images: [UIImage]) {
        _images = images
        
        p_updateImage()
    }
    
    func updateImages(byIDs fileIDs: [String]) {
        _fileIDs = fileIDs
        
        p_updateImagesByFileIDs()
    }
    
    override func layoutSubviews() {
        if kArrIsEmpty(_fileIDs) {
            p_updateImage()
        } else {
            p_updateImagesByFileIDs()
        }
    }
}

// MARK: - Private Methods
private extension MSTNineImagesView {
    func p_initView() {
        backgroundColor = .white
        
        var showCount = _images?.count ?? 0
        if showCount < 9 && _style == .edit {
            showCount += 1
        } else if _style == .editFull {
            showCount = maxCount
        }
        
        for i in 1...9 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = kBgColor
            imageView.tag = i
            
            let delView = UIImageView()
            delView.image = UIImage(named: "mst_image_delete", in: kMSTBundle, compatibleWith: nil)
            delView.contentMode = .topRight
            delView.clipsToBounds = true
            delView.isUserInteractionEnabled = true
            delView.tag = i
            imageView.addSubview(delView)
            
            let delBtn = UIButton(type: .custom)
            delBtn.tag = i
            delBtn.addTarget(self, action: #selector(p_deleteAction(_:)), for: .touchUpInside)
            delView.addSubview(delBtn)
            
            imageView.mst_addTapGesture(target: self, action: #selector(p_imageViewTapped(_:)))
            
            addSubview(imageView)
        }
        
        p_updateImage()
    }
    
    func p_updateImage() {
        var showCount = _images?.count ?? 0
        
        _imageViews.removeAll()
        
        if showCount < maxCount && _style == .edit {
            showCount += 1
        } else if _style == .editFull {
            showCount = maxCount
        }
        
        for i in 1...9 {
            let imageView = viewWithTag(i) as! UIImageView
            
            if i > showCount {
                imageView.isHidden = true
                imageView.frame = .zero
            } else {
                imageView.isHidden = false
                imageView.frame = p_imageViewFrame(i)
                
                
                if _style == .edit && i == showCount && _images?.count != maxCount {
                    imageView.image = kArrIsEmpty(addPlaceholder) ? UIImage(named: "mst_image_add", in: kMSTBundle, compatibleWith: nil) : UIImage(named: addPlaceholder.first!)
                    imageView.mst_subview(tag: i)!.isHidden = true
                } else if _style == .editFull {
                    var image = _images?[safe: i-1]

                    if image == nil || image?.size == .zero {
                        image = UIImage(named: addPlaceholder[safe: i-1] ?? "")
                        if image == nil || image?.size == .zero {
                            image = UIImage(named: "mst_image_add", in: kMSTBundle, compatibleWith: nil)
                        }
                    }
                    imageView.image = image
                    imageView.mst_subview(tag: i)!.isHidden = false
                } else {
                    imageView.image = _images![i-1]
                    
                    if _style == .edit {
                        let delView = imageView.mst_subview(tag: i)!
                        let delBtn = delView.mst_subview(tag: i)!
                        
                        delView.frame = CGRect(x: imageView.mst_width-24, y: 0, width: 24, height: 24)
                        delBtn.frame = delView.bounds
                        
                        delView.isHidden = false
                    } else {
                        imageView.mst_subview(tag: i)!.isHidden = true
                    }
                    
                    _imageViews.append(imageView)
                }
            }
        }
    }
    
    func p_updateImagesByFileIDs() {
        let showCount = _fileIDs?.count ?? 0
        
        _imageViews.removeAll()
        
        for i in 1...9 {
            let imageView = viewWithTag(i) as! UIImageView

            if i > showCount {
                imageView.isHidden = true
                imageView.frame = .zero
            } else {
                imageView.isHidden = false
                imageView.frame = p_imageViewFrame(i)

                imageView.sd_setImage(with: URL(string: _fileIDs![i-1]), completed: nil)
                imageView.subviews.first!.isHidden = true
                
                _imageViews.append(imageView)
            }
        }

    }
    
    func p_imageViewFrame(_ idx: Int) -> CGRect {
        var count = kArrIsEmpty(_fileIDs) ? (_images?.count ?? 0) : (_fileIDs?.count ?? 0)
        
        // 当为编辑模式的时候, 展示按照9个计算
        if _style == .edit || !_isZoom {
            count = 9
        } else if _style == .editFull {
            count = maxCount
        }

        var row = (idx - 1)/3
        var column = (idx - 1)%3
        
        let size = MSTNineImagesView.p_imageViewSize(count: count, viewWidth: mst_width, displayType: _type)
        
        if count == 4 {
            row = (idx - 1)/2
            column = (idx - 1)%2
        }
        
        return CGRect(x: CGFloat(column)*(size.width + _padding), y: CGFloat(row)*(size.width + _padding), width: size.width, height: size.height)
    }
}

// MARK: - Actions
extension MSTNineImagesView {
    @objc private func p_deleteAction(_ sender: UIButton) {
        _images!.remove(at: sender.tag-1)
        
        p_updateImage()
        
        delegate?.nineImagesView?(self, shouldDeleteAtIndex: sender.tag-1)
    }
    
    @objc private func p_imageViewTapped(_ gesture: UITapGestureRecognizer) {
        if (_style == .edit && (_images?.count ?? 0) == gesture.view!.tag - 1) || _style == .editFull {
            delegate?.nineImagesViewShouldAddImage?(self, idx: gesture.view!.tag - 1)
        } else {
            delegate?.nineImagesView?(self, didselectedAtIndex: gesture.view!.tag-1, imageViews: _imageViews)
        }
    }
}
