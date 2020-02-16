//
//  RYSkillFlowLayout.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/12.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

let kRYCellNumberOfOneRow: Int = 3
let kRYCellRow: Int = 2

class RYSkillFlowLayout: UICollectionViewFlowLayout {

//    fileprivate var attributesArr: [UICollectionViewLayoutAttributes] = [] // saves all attributes
    
    // MARK: -
    override func prepare() {
        super.prepare()
        
        // setup itemSize
        let w: CGFloat = 160
        let h: CGFloat = 160 * 9/16
        itemSize = CGSize(width: w, height: h)
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
        sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        scrollDirection = .horizontal
        
//        let itemsCount = kRYCellNumberOfOneRow*kRYCellRow
//        for itemIndex in 0..<itemsCount {
//            let section = itemIndex / kRYCellNumberOfOneRow
//            let row = itemIndex % kRYCellNumberOfOneRow
//            let indexPath = IndexPath(item: row, section: section)
//            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//            let left: CGFloat = 10
//            let gap: CGFloat = 10
//            let top: CGFloat = 5
//            let x: CGFloat = left + (gap+w)*CGFloat(row)
//            let y: CGFloat = top + (gap+h)*CGFloat(section)
//            attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
//            attributesArr.append(attributes)
//        }
        
    }

//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        var rectAttributes: [UICollectionViewLayoutAttributes] = []
//        _ = attributesArr.map({
//            if rect.contains($0.frame) {
//                rectAttributes.append($0)
//            }
//        })
//        return rectAttributes
//    }
}
