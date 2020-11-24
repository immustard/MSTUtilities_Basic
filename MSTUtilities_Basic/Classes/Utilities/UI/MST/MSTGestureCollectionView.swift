//
//  MSTGestureCollectionView.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/7/15.
//

import UIKit

open class MSTGestureCollectionView: UICollectionView {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
