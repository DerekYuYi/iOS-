//
//  RYHPHeaderView.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/10.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit
import PPBadgeViewSwift

@objc protocol RYHPHeaderViewDelegate: NSObjectProtocol {
    @objc optional func headerView(_ headerView: RYHPHeaderView, clearButtonTapped: UIButton)
    @objc optional func headerView(_ headerView: RYHPHeaderView, moreButtonTapped: UIButton)
}

/// optional methods by extension
//extension RYHPHeaderViewDelegate {
//    func headerView(_ headerView: RYHPHeaderView, moreButtonTapped: UIButton) {}
//    func headerView(_ headerView: RYHPHeaderView, clearButtonTapped: UIButton) {}
//}

class RYHPHeaderView: UICollectionReusableView {
    
    // MARK: - Outlets
    
    @IBOutlet weak var flagView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    // MARK: - Properties
    
    weak var delegate: RYHPHeaderViewDelegate?
    var sectionType: eRYHPSectionType?
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        flagView.roundedCorner(nil, 1)
        clearButton.setTitle("清除", for: .normal)
    }
    
    func update(_ data: String) {
        guard !data.isEmpty else { return }
        titleLabel.text = data
    }
    
    func enableMoreButton(_ enabled: Bool) {
        moreButton.isHidden = !enabled
        moreButton.isEnabled = enabled
        moreButton.isUserInteractionEnabled = enabled
    }
    
    func enableClearButton(_ enabled: Bool) {
        clearButton.isHidden = !enabled
        clearButton.isEnabled = enabled
        clearButton.isUserInteractionEnabled = enabled
        clearButton.roundedCorner(nil, 9.0)
    }
    
    // MARK: - Touch events
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        delegate?.headerView?(self, moreButtonTapped: sender)
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        delegate?.headerView?(self, clearButtonTapped: sender)
    }
    
}

// MARK: - Badge Red Point

extension RYHPHeaderView {
    
    func showBadgeView(_ isShow: Bool) {
        if isShow {
            self.moreButton.pp.addDot(color: .red)
            self.moreButton.pp.setBadge(height: 9)
        } else {
            self.moreButton.pp.hiddenBadge()
        }
    }
}
