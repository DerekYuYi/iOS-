//
//  RYPublishChooseTypeCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/10.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYPublishChooseTypeCell: UITableViewCell {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var arrowDownImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if #available(iOS 11.0, *) {
            cornerView.backgroundColor = UIColor(named: "Color_FCFCFC")
        } else {
            cornerView.backgroundColor = .white
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
                arrowDownImageView.tintColor = .black
            } else {
                cornerView.layer.borderColor = UIColor.white.cgColor
                arrowDownImageView.tintColor = .white
            }
        } else {
            cornerView.layer.borderColor = RYColors.color(from: 0xF3F1F1).cgColor
            arrowDownImageView.tintColor = .black
        }
    }
    
    func update(_ type: RYTypeItem) {
        typeLabel.text = type.name
    }
    
    func rotate(_ isUnFold: Bool) {
        
        UIView.animate(withDuration: 1.0) {
            if isUnFold {
                self.arrowDownImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            } else {
                self.arrowDownImageView.transform = CGAffineTransform.identity
            }
        }
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
