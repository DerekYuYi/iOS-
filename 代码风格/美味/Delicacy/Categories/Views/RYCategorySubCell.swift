//
//  RYCategorySubCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/6.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

protocol RYCategorySubCellDelegate: NSObjectProtocol {
    func subCategoryCell(_ cell: RYCategorySubCell, didSelectedCategory categoryName: String)
}

private let kRYGap: CGFloat = 10
private let kRYHeightForCellTitle: CGFloat = 19

class RYCategorySubCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: RYCategorySubCellDelegate?
    private var flowLayout = UICollectionViewFlowLayout()
    
    private var subCategories: [RYCategoryModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = RYColors.gray_mid
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.roundedCorner()
        collectionView.isScrollEnabled = false
        
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical  /// NOTE: vertical direction
        collectionView.collectionViewLayout = flowLayout
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // NOTE: Why collectionView's bounds not adapt screen?
        let width = (contentView.bounds.width - kRYGap*2 - 5*2) / CGFloat(kRYCountOfItemsPerRow)
        flowLayout.itemSize = CGSize(width: width, height: width + kRYHeightForCellTitle)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.sectionInset = UIEdgeInsets(top: kRYGap/2.0, left: kRYGap, bottom: kRYGap/2, right: kRYGap)
    }
    
    func update(_ data: [RYCategoryModel]) {
        subCategories = data
    }
}

private let kRYCountOfItemsPerRow: Int = 3

extension RYCategorySubCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard subCategories.count > 0 else {
            return 0
        }
        return numberOfSections()
    }
    
    private func numberOfSections() -> Int {
        let divisor = subCategories.count / kRYCountOfItemsPerRow
        let a = subCategories.count % kRYCountOfItemsPerRow == 0 ? divisor : divisor + 1
        return a
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard subCategories.count > 0 else {
            return 0
        }
        
        if section == numberOfSections() - 1 {
            if subCategories.count % kRYCountOfItemsPerRow == 0 {
                return kRYCountOfItemsPerRow
            }
            return subCategories.count % kRYCountOfItemsPerRow
        }
        return kRYCountOfItemsPerRow
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RYCategoryDetailsCell", for: indexPath)
        let index: Int = indexPath.section*kRYCountOfItemsPerRow + indexPath.row
         if let cell = cell as? RYCategoryDetailsCell, index < subCategories.count {
             cell.update(subCategories[index])
         }
         return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 1. UI
//        scaleCell(collectionView.cellForItem(at: indexPath), true)
        
        // 2. Logic
        let index: Int = indexPath.section*kRYCountOfItemsPerRow + indexPath.row
        if index < subCategories.count {
            if let name = subCategories[index].name {
                collectionView.deselectItem(at: indexPath, animated: true)
                delegate?.subCategoryCell(self, didSelectedCategory: name)
            }
        }
     }
    
    /*
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        scaleCell(collectionView.cellForItem(at: indexPath), false)
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        scaleCell(collectionView.cellForItem(at: indexPath), true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        scaleCell(collectionView.cellForItem(at: indexPath), false)
    }
    
    func scaleCell(_ cell: UICollectionViewCell?, _ isScale: Bool) {
        guard let cell = cell else { return }
        if isScale {
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }
    
    
}

// MARK: - Cache for calculated indexpath
struct RYCategorySubCellHeightCache {
    var indexpaths: Set<IndexPath> = []
    var cachedHeights: [IndexPath: CGFloat] = [:]
    
    func calculateCellHeight(_ itemsCount: Int, width: CGFloat) -> CGFloat {
        let divisor = itemsCount / kRYCountOfItemsPerRow
        let sections = itemsCount % kRYCountOfItemsPerRow == 0 ? divisor : divisor + 1
        let itemTop = kRYGap/2.0
        let itemBottom = kRYGap/2.0
        let gaps = (itemTop+itemBottom) * CGFloat(sections)
        
        let itemWidth = (width - kRYGap*2 - 5*2) / CGFloat(kRYCountOfItemsPerRow)
        let itemHeight = itemWidth + kRYHeightForCellTitle
        return CGFloat(sections) * itemHeight + gaps
    }
    
    mutating func cacheHeight(for indexPath: IndexPath, willCacheHeight: CGFloat) {
        guard !indexpaths.contains(indexPath) else { return }
        indexpaths.update(with: indexPath)
        cachedHeights.updateValue(willCacheHeight, forKey: indexPath)
    }
    
    func isCachedHeight(for indexPath: IndexPath) -> Bool {
        if indexpaths.contains(indexPath) {
            return true
        }
        return false
    }
    
    func cachedHeight(for indexPath: IndexPath) -> CGFloat {
        guard isCachedHeight(for: indexPath) else { return 1.0 }
        if let height = cachedHeights[indexPath] {
            return height
        }
        return 1.0
    }
    
    
}
