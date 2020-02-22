//
//  RYFlagsView.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/4.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

protocol RYFlagsViewDelegate: NSObjectProtocol {
    func flagsViewDidSelectChannel(at channel: String)
}

extension RYFlagsViewDelegate {
    func flagsViewDidSelectChannel(at channel: String) {}
}

/// A view used to show multiple news labels.
class RYFlagsView: UIView, RYNibLoadable {
    
    private struct Constants {
        static let identifierForCollectionItemCell = String(describing: RYNewsCollectionItemCell.self)
    }
    
    private let channels = ["推荐", "娱乐", "热点", "科技", "体育", "旅游"]
    
    weak var delegate: RYFlagsViewDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(UINib(nibName: Constants.identifierForCollectionItemCell, bundle: nil), forCellWithReuseIdentifier: Constants.identifierForCollectionItemCell)
    }
}


// MARK: - UICollectionViewDelegate && UICollectionViewDataSource

extension RYFlagsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard channels.count > 0 else { return 0 }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard channels.count > 0 else { return 0 }
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.identifierForCollectionItemCell, for: indexPath)
        if let cell = cell as? RYNewsCollectionItemCell, indexPath.row < channels.count {
            cell.update(channels[indexPath.row], isSelected: indexPath.row == RYFlagRecorder.flag)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // change the selectedIndex
        guard indexPath.row < channels.count else { return }
        guard RYFlagRecorder.flag != indexPath.row else { return }
        
        RYFlagRecorder.flag = indexPath.row
        
        // reload collection view and reload label
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        // delegate
        delegate?.flagsViewDidSelectChannel(at: channels[indexPath.row])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RYFlagsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard channels.count > 0 else {
            return CGSize.zero
        }
        let width = collectionView.bounds.width / CGFloat(channels.count)
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

/// Records the news flag value.
struct RYFlagRecorder {
    static var flag: Int = 0
    
    /*
    static func recordFlag(at index: Int) {
        flag = index
    }
    */
}
