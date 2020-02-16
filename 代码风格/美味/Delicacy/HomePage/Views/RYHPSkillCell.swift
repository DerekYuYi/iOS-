//
//  RYHPSkillCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/10.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

protocol RYHPSkillCellDelegate: NSObjectProtocol {
    func skillCell(_ cell: RYHPSkillCell?, didSelectItemAt skillID: Int)
}

class RYHPSkillCell: UITableViewCell {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var skills: [RYSKill] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    weak var delegate: RYHPSkillCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        // customize flow layout
//        collectionView.collectionViewLayout = RYSkillFlowLayout()
    }
    
    func update(_ data: [RYSKill]) {
        skills = data
    }
}

private let kRYItemOfPerSection: Int = 4
private let kRYEdgeInset_horizontal: CGFloat = 10
private let kRYEdgeInset_vertical: CGFloat = 5
private let kRYMinimumLineSpacing: CGFloat = 10
private let kRYVideoWidth: CGFloat = 160
private let kRYVideoRatio: CGFloat = 16.0/9.0

extension RYHPSkillCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard skills.count > 0 else { return 0 }
        
        if section == numberOfSections() - 1 {
            if skills.count % kRYItemOfPerSection == 0 {
                return kRYItemOfPerSection
            }
            return skills.count % kRYItemOfPerSection
        }
        return kRYItemOfPerSection
    }
    
    private func numberOfSections() -> Int {
        let divisor = skills.count / kRYItemOfPerSection
        let count = skills.count % kRYItemOfPerSection == 0 ? divisor : divisor + 1
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RYSkillCollectionCell", for: indexPath)
        let index = indexPath.section*kRYItemOfPerSection + indexPath.row
        if let cell = cell as? RYSkillCollectionCell,
            index < skills.count {
            cell.update(skills[index])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let index = indexPath.section*kRYItemOfPerSection + indexPath.row
        if index < skills.count {
            let selectedSkill = skills[index]
            if let skillID = selectedSkill.iD {
                delegate?.skillCell(self, didSelectItemAt: skillID)
            }
        }
    }
    
    // MARK: - Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kRYVideoWidth, height: kRYVideoWidth/kRYVideoRatio + 32) // 32 is adapt for bottom label height
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
           return UIEdgeInsets(top: kRYEdgeInset_vertical, left: kRYEdgeInset_horizontal, bottom: kRYEdgeInset_vertical, right: 0)
        } else {
            return UIEdgeInsets(top: kRYEdgeInset_vertical, left: kRYEdgeInset_horizontal, bottom: kRYEdgeInset_vertical, right: kRYEdgeInset_horizontal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kRYMinimumLineSpacing
    }
    
}
