//
//  MSTLabel.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/6/17.
//

import UIKit

public enum VerticalAlignment {
    case top
    
    case middle
    
    case bottom
}

open class MSTLabel: UILabel {

    public var verticalAlignment : VerticalAlignment?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.verticalAlignment = VerticalAlignment.middle
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect: CGRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch self.verticalAlignment {
        case .top?:
            textRect.origin.y = bounds.origin.y
        case .bottom?:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
        case .middle?:
            fallthrough
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0
        }
        return textRect
    }
    
    open override func draw(_ rect: CGRect) {
        let rect : CGRect = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: rect)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
