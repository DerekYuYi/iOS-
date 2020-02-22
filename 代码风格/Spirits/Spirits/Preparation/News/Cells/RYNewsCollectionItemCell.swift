//
//  RYNewsCollectionItemCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/4.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYNewsCollectionItemCell: UICollectionViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bottomTrackingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.text = "推荐"
        contentLabel.textColor = .lightGray
        contentLabel.font = UIFont(name: "PingFangSC-Semibold", size: 15)
        bottomTrackingView.isHidden = true
    }
    
    func update(_ text: String, isSelected: Bool) {
        contentLabel.text = text
        if isSelected {
            contentLabel.textColor = .black
            contentLabel.font = UIFont(name: "PingFangSC-Semibold", size: 18)
            bottomTrackingView.isHidden = false
        } else {
            contentLabel.textColor = UIColor.lightGray
            contentLabel.font = UIFont(name: "PingFangSC-Semibold", size: 15)
            bottomTrackingView.isHidden = true
        }
    }

}
