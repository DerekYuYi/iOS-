//
//  RYProfileCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYProfileCell: UITableViewCell {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowRightImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if #available(iOS 11.0, *) {
            contentView.backgroundColor = UIColor(named: "Color_f1f8f9")
        } else {
            contentView.backgroundColor = RYColors.color(from: 0xf1f8f9)
        }
        
        cornerView.layer.masksToBounds = true
        cornerView.layer.cornerRadius = 5.0
        cornerView.layer.borderWidth = 1.0
        configForUserInterfaceStyle()
    }
    
    private func configForUserInterfaceStyle() {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                cornerView.layer.borderColor = RYColors.color(from: 0xF3F1F1).cgColor
            } else {
                cornerView.layer.borderColor = UIColor.white.cgColor
            }
        } else {
            cornerView.layer.borderColor = RYColors.color(from: 0xF3F1F1).cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let selectedbackgroundView = selectedBackgroundView {
            let gap: CGFloat = 15.0
            selectedbackgroundView.frame = CGRect(x: gap, y: 0.0, width: bounds.width - gap*2, height: bounds.height)
            
            selectedbackgroundView.layer.masksToBounds = true
            selectedbackgroundView.layer.cornerRadius = 5.0
        }
    }
    
    func update(_ itemData: PersonItemData) {
        if itemData.imageName.isEmpty {
            contentImageView.isHidden = true
            titleLabel.textColor = RYColors.color(from: 0x999999)
            
        } else {
            titleLabel.textColor = RYColors.color(from: 0x333333)
            contentImageView.isHidden = false
            contentImageView.image = UIImage(named: itemData.imageName)
        }
        
        titleLabel.text = itemData.title
    }
    
    func hiddenRightArrow() {
        arrowRightImageView.isHidden = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                configForUserInterfaceStyle()
            }
        }
    }

}
