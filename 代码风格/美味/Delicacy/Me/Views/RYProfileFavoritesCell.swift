//
//  RYProfileFavoritesCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/4/4.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYProfileFavoritesCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cornerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.clipsToBounds = false
        
        cornerView.roundedCorner()
        cornerView.backgroundColor = .white
        
        shadowView.clipsToBounds = false
        shadowView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 7.0
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 1)
        shadowView.layer.shadowOpacity = 0.6
        
    }
    
    func shakeContentView() {
        if !RYUserDefaultCenter.hasShownFavoriteBadge() {
            cornerView.shake(for: "position", duration: 5.0, repeatCount: 5)
        }
    }
}
