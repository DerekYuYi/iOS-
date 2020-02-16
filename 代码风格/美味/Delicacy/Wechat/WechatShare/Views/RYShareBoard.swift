//
//  RYShareBoard.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/1/25.
//  Copyright © 2019 SmartRuiYu. All rights reserved.
//

import UIKit

protocol RYShareBoardDelegate: NSObjectProtocol {
    func shareToWechat(for scene:WXScene)
}

private let kRYMReuseIndentifierForShareItem = "RYShareItemCell"

class RYShareBoard: UIView {
    
    weak var delegate: RYShareBoardDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let shareItems: [[String: String]] = [["微信好友": "wechat_friend"],
                                                  ["微信朋友圈": "wechat_timeline"]]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: kRYMReuseIndentifierForShareItem, bundle: nil), forCellWithReuseIdentifier: kRYMReuseIndentifierForShareItem)
    }
    
    // MARK: - Provides preferred item'width and height
    func preferredHeight() -> CGFloat {
        let verticalGap: CGFloat = 12.0
        let margin: CGFloat = 3.0
        let imageViewHeight: CGFloat = 60.0
        let titleHeight: CGFloat = 17.0
        return verticalGap*2 + margin + imageViewHeight + titleHeight
    }
    
    func preferredWidth() -> CGFloat {
        let horizontalGap: CGFloat = 16.0
        let imageViewHeight: CGFloat = 60.0
        return horizontalGap*2 + imageViewHeight
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource && UICollectionViewDelegateFlowLayout
extension RYShareBoard: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kRYMReuseIndentifierForShareItem, for: indexPath)
        if let cell = cell as? RYShareItemCell, indexPath.row < shareItems.count {
            cell.update(shareItems[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard shareItems.count > 0, indexPath.row < shareItems.count else {
            return
        }
        
        if indexPath.row == 0 {
            delegate?.shareToWechat(for: WXSceneSession)
        } else if indexPath.row == 1 {
            delegate?.shareToWechat(for: WXSceneTimeline)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: preferredWidth(), height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
