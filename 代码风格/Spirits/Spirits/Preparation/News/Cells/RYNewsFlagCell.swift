//
//  RYNewsFlagCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/2.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYNewsFlagCell: UITableViewCell {
    
    private let channels = ["推荐", "娱乐", "热点", "科技", "体育", "旅游"]
    private var selectedIndex = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
    }
    
}


// MARK: - UICollectionViewDelegate && UICollectionViewDataSource

extension RYNewsFlagCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard channels.count > 0 else { return 0 }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard channels.count > 0 else { return 0 }
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RYNewsCollectionItemCell", for: indexPath)
        if let cell = cell as? RYNewsCollectionItemCell, indexPath.row < channels.count {
            cell.update(channels[indexPath.row], isSelected: indexPath.row == selectedIndex)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // load new pages
    }
}

extension RYNewsFlagCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard channels.count > 0 else {
            return CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude)
        }
        let width = collectionView.bounds.width / CGFloat(channels.count)
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //        return CGFloat.leastNormalMagnitude
    //    }
    
    
}
