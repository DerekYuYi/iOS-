//
//  RYFavoritesTopTypeCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/11.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYFavoritesTopTypeCell: UICollectionViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var trackingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.isSelectedContentLabel(false)
        
        trackingView.layer.masksToBounds = true
        trackingView.layer.cornerRadius = 1.5
    }
    
    func isSelectedContentLabel(_ isSelected: Bool) {
        
        if isSelected {
            contentLabel.textColor = RYColors.color(from: 0x333333)
            contentLabel.font = UIFont(name: "PingFangSC-Medium", size: 20)
        } else {
            contentLabel.textColor = RYColors.color(from: 0xC0BFBD)
            contentLabel.font = UIFont(name: "PingFangSC-Medium", size: 18)
        }
        
        trackingView.isHidden = !isSelected
    }
    
    func update(_ typeName: String?, isSelected: Bool) {
        contentLabel.text = typeName
        isSelectedContentLabel(isSelected)
    }

}
