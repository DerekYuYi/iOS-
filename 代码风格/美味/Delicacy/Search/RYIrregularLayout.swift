//
//  RYIrregularLayout.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/17.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

protocol RYIrregularLayoutDataSource: NSObjectProtocol {
    /// get section size
    func collectionViewLayout(_ collectionViewLayout: RYIrregularLayout, sizeForSectionAt indexPath: IndexPath) -> CGSize
    /// get item size
    func collectionViewLayout(_ collectionViewLayout: RYIrregularLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}

class RYIrregularLayout: UICollectionViewLayout {
    
    var rowSpacing: CGFloat = 0.0
    var columnSpacing: CGFloat = 0.0
    weak var dataSource: RYIrregularLayoutDataSource?
    
    private var itemFrames: [[CGRect]] = [] /// two-dimensional (section / item)
    private var sectionFrames: [CGRect] = []
    private var atts: [UICollectionViewLayoutAttributes] = []
    
    
    /// Calculate all items's frame
    override func prepare() {
        super.prepare()
        setupItemsFrames()
    }
    
    private func setupItemsFrames() {
        guard let collectionView = collectionView, let dataSource = dataSource else { return }
        itemFrames.removeAll()
        sectionFrames.removeAll()
        atts.removeAll()
        
        let sectionCount = collectionView.numberOfSections
        for sectionIndex in 0..<sectionCount {
            // 1. section
            
            let sectionIndexPath = IndexPath(item: 0, section: sectionCount)
            /// 对应 section 中的 item 数量
            let itemCount = collectionView.numberOfItems(inSection: sectionIndex)
            
            let sectionHeight: CGFloat = dataSource.collectionViewLayout(self, sizeForSectionAt: sectionIndexPath).height
            if sectionIndex == 0 {
                let sectionFrame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: sectionHeight)
                sectionFrames.append(sectionFrame)
            } else {
                let lastItemCount = collectionView.numberOfItems(inSection: sectionIndex - 1)
                let lastItemFrame = itemFrames[sectionIndex - 1][lastItemCount - 1]
                let sectionFrame = CGRect(x: 0, y: lastItemFrame.maxY, width: collectionView.bounds.width, height: sectionHeight)
                sectionFrames.append(sectionFrame)
            }
            
            // 2. item whthin section
            let attr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(row: 0, section: sectionIndex))
            attr.frame = sectionFrames[sectionIndex]
            atts.append(attr)
            var helperFrames: [CGRect] = []
            for itemIndex in 0..<itemCount {
                let size = dataSource.collectionViewLayout(self, sizeForItemAt: IndexPath(item: itemIndex, section: sectionIndex))
                if itemIndex == 0 {
                    let sectionFrame = sectionFrames[sectionIndex]
                    helperFrames.append(CGRect(x: 0, y: sectionFrame.maxY, width: size.width, height: size.height))
                } else {
                    let lastFrame = helperFrames[itemIndex - 1]
                    if (lastFrame.maxX + columnSpacing + size.width) < collectionView.bounds.width {
                        helperFrames.append(CGRect(x: lastFrame.maxX + columnSpacing, y: lastFrame.minY, width: size.width, height: size.height))
                    } else {
                        helperFrames.append(CGRect(x: 0, y: lastFrame.maxY + self.rowSpacing, width: size.width, height: size.height))
                    }
                }
                let itemAttr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: itemIndex, section: sectionIndex))
                itemAttr.frame = helperFrames[itemIndex]
                atts.append(itemAttr)
            }
            itemFrames.append(helperFrames)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize(width: 0, height: 0)
        }
        
        if let lastFrame = itemFrames.last?.last {
           let lastItemMaxY = lastFrame.maxY
            return CGSize(width: 0, height: lastItemMaxY > collectionView.bounds.height ? lastItemMaxY : collectionView.bounds.height + 1)
        }
        return CGSize(width: 0, height: 0)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return atts
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let itemAttrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        itemAttrs.frame = itemFrames[indexPath.section][indexPath.item]
        return itemAttrs
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let headerAttrs = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        headerAttrs.frame = sectionFrames[indexPath.section]
        return headerAttrs
    }
}
