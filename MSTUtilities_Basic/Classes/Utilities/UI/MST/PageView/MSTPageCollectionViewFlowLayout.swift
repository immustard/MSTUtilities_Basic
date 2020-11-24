//
//  MSTPageCollectionViewFlowLayout.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/11/19.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit

open class MSTPageCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var offset: CGFloat?
    
    override open func prepare() {
        super.prepare()
        guard let offset = offset else { return }
        collectionView?.contentOffset = CGPoint(x: offset, y: 0)
    }
}
