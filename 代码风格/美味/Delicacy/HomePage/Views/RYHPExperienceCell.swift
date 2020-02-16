//
//  RYHPExperienceCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/10.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

protocol RYHPExperienceCellDelegate: AnyObject {
    func experienceCell(_ cell: RYHPExperienceCell?, didSelectItemAt dishID: Int)
}

class RYHPExperienceCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: RYHPExperienceCellDelegate?
    
    private var experiences: [RYExperience] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
    }
    
    func update(_ data: [RYExperience]) {
        experiences = data
    }

}

fileprivate let kRYEdgeInset_horizontal: CGFloat = 10
fileprivate let kRYEdgeInset_vertical: CGFloat = 5

extension RYHPExperienceCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RYExperienceCollectionCell", for: indexPath)
        if let cell = cell as? RYExperienceCollectionCell, indexPath.item < experiences.count {
            cell.update(experiences[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < experiences.count else {
            return
        }
        if let dishID = experiences[indexPath.row].iD {
            collectionView.deselectItem(at: indexPath, animated: true)
            delegate?.experienceCell(self, didSelectItemAt: dishID)
        }
    }
    
    // MARK: - Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width-kRYEdgeInset_horizontal*3) / 2, height: (self.bounds.height - kRYEdgeInset_vertical*2 - kRYEdgeInset_horizontal)/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: kRYEdgeInset_vertical, left: kRYEdgeInset_horizontal, bottom: kRYEdgeInset_vertical, right: kRYEdgeInset_horizontal)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kRYEdgeInset_horizontal
    }
    
}
