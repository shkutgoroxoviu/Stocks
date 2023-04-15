//
//  SettingsHistoryCollection.swift
//  Stocks
//
//  Created by Oleg on 28.03.2023.
//

import Foundation
import UIKit

class MyCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 5
        minimumLineSpacing = 2
        sectionInset = UIEdgeInsets(top: 30, left: 5, bottom: 5, right: 5)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementKind == UICollectionView.elementKindSectionHeader {
                layoutAttribute.frame.origin.x = collectionView?.contentOffset.x ?? 0
            }
        }
        return attributes
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
