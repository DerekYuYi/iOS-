//
//  RYSkillCollectionCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/11.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit
import Kingfisher

class RYSkillCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.18) {
                    self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                }
            } else {
                UIView.animate(withDuration: 0.18) {
                    self.transform = .identity
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.roundedCorner()
        imageView.backgroundColor = RYColors.gray_imageViewBg
        imageView.contentMode = .scaleAspectFill
        imageView.kf.indicatorType = .activity
    }
    
    func update(_ data: RYSKill) {
        if let imageUrlString = data.imageUrlString, let url = URL(string: imageUrlString) {
            imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
        }
        
        if let title = data.title {
            titleLabel.text = title
        }
        
        if let timeValue = data.playTime {
            timeLabel.text = timeValue
        }
    }
    
}
