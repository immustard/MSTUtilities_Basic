//
//  MSTCollectionViewLeftAlignedLayout.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/12/11.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

public protocol MSTCollectionViewDelegateLeftAlignedLayout: UICollectionViewDelegateFlowLayout {
    
}

open class MSTCollectionViewLeftAlignedLayout: UICollectionViewFlowLayout {
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let originalAttributes = super.layoutAttributesForElements(in: rect) {
            var updatedAttributes = Array(originalAttributes)
            
            for attribute in originalAttributes {
                if attribute.representedElementKind == nil {
                    let idx = updatedAttributes.firstIndex(of: attribute)!
                    updatedAttributes[idx] = layoutAttributesForItem(at: attribute.indexPath)!
                }
            }
            
            return updatedAttributes
        } else {
            return nil
        }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)
        let sectionInset = p_evaluatedSectionInsetForItem(at: indexPath.section)
        
        let isFirstItemInSection = indexPath.item == 0
        let layoutWidth = collectionView!.frame.width - sectionInset.left - sectionInset.right
        
        if isFirstItemInSection {
            currentItemAttributes?.leftAlignFrame(sectionInset: sectionInset)
            return currentItemAttributes
        }
        
        let previousIndexPath = IndexPath(item: indexPath.item-1, section: indexPath.section)
        let previousFrame = layoutAttributesForItem(at: previousIndexPath)?.frame
        let previousFrameRightPoint: CGFloat = (previousFrame?.origin.x ?? 0) + (previousFrame?.size.width ?? 0)
        let currentFrame = currentItemAttributes?.frame
        let strectchedCurrentFrame = CGRect(x: sectionInset.left, y: currentFrame?.minY ?? 0, width: layoutWidth, height: currentFrame?.height ?? 0)
        
        let isFirstItemInRow = !(previousFrame?.intersects(strectchedCurrentFrame) ?? true)
        
        if isFirstItemInRow {
            currentItemAttributes?.leftAlignFrame(sectionInset: sectionInset)
            return currentItemAttributes
        }
        
        var frame = currentItemAttributes?.frame
        frame?.origin.x = previousFrameRightPoint + p_evaluatedMinimumInteritemSpacintForSection(at: indexPath.section)
        currentItemAttributes?.frame = frame ?? .zero
        
        return currentItemAttributes
    }
    
    private func p_evaluatedMinimumInteritemSpacintForSection(at index: Int) -> CGFloat {
        if self.collectionView?.delegate?.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))) ?? false {
            let delegate: MSTCollectionViewDelegateLeftAlignedLayout = self.collectionView!.delegate as! MSTCollectionViewDelegateLeftAlignedLayout
            return delegate.collectionView!(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: index)
        } else {
            return minimumInteritemSpacing
        }
    }
    
    private func p_evaluatedSectionInsetForItem(at index: Int) -> UIEdgeInsets {
        if self.collectionView?.delegate?.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))) ?? false {
            let delegate: MSTCollectionViewDelegateLeftAlignedLayout = self.collectionView!.delegate as! MSTCollectionViewDelegateLeftAlignedLayout
            return delegate.collectionView!(collectionView!, layout: self, insetForSectionAt: index)
        } else {
            return sectionInset
        }
    }
}

extension UICollectionViewLayoutAttributes {
    open func leftAlignFrame(sectionInset: UIEdgeInsets) {
        var frame = self.frame
        frame.origin.x = sectionInset.left
        self.frame = frame
    }
}
