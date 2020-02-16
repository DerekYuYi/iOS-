//
//  RYCardFlowLayout.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/3/20.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYCardFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    override func prepare() {
        
    }
    */
 
    
    /*
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let array = super.layoutAttributesForElements(in: rect),
            let collectionView = self.collectionView else { return nil }
        
        let visibleRect = CGRect(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y, width: collectionView.bounds.width, height: collectionView.bounds.height)
        
        let maxCenterMargin = collectionView.bounds.width * 0.5 + self.itemSize.width * 0.5
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width * 0.5
        for attributes in array {
            if visibleRect.intersects(attributes.frame) { continue }
            
            let scale = 1 + (0.8 - abs(centerX - attributes.center.x) / maxCenterMargin)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        return array
    }
    */
    
    /*
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
        guard let _ = self.collectionView else { return nil }
        
        attributes.alpha = 1.0
        
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
        
        attributes.alpha = 1.0
        
        return attributes
    }
    */
}
