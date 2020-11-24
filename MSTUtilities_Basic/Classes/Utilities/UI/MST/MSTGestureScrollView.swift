//
//  MSTGestureScrollView.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/7/14.
//

import UIKit

open class MSTGestureScrollView: UIScrollView, UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
