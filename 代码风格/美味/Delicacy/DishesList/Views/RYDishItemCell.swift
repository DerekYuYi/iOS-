//
//  RYDishItemCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/19.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Kingfisher

class RYDishItemCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundView: UIView!
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var browseLabel: UILabel!
    @IBOutlet weak var collectionLabel: UILabel!
    
    
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
        // Initialization code
        contentView.clipsToBounds = false
        shadowView.clipsToBounds = false
    
        shadowView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 7.0
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 1)
        shadowView.layer.shadowOpacity = 0.6
        
        // https://stackoverflow.com/questions/37645408/uitableviewcell-rounded-corners-and-shadow
        // https://stackoverflow.com/questions/4754392/uiview-with-rounded-corners-and-drop-shadow/34984063#34984063
        // https://stackoverflow.com/questions/12927626/shadow-not-showing-when-background-color-is-clear-color/12928417#12928417
        /*
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: radius).cgPath
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        */
        // corder
        roundView.roundedCorner()
        roundView.backgroundColor = .white
        
        // data subviews
        dishImageView.roundedCorner()
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.backgroundColor = RYColors.gray_imageViewBg
        dishImageView.kf.indicatorType = .activity
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // adapt selectedbackgroundView's frame
        if let selectedBackgroundView = selectedBackgroundView {
            selectedBackgroundView.frame = roundView.frame
            selectedBackgroundView.roundedCorner()
        }
    }
    
    func update(_ data: RYDishModel) {
        if let title = data.title {
            titleLabel.text = title
        }
        
        if let desc = data.introduction {
            detailsLabel.text = desc
        }
        
        if let browseCount = data.read_number {
            browseLabel.text = "\(browseCount)"
        } else {
            browseLabel.text = "0"
        }
        
        if let collectionCount = data.collection_count {
            collectionLabel.text = "\(collectionCount)"
        } else {
            collectionLabel.text = "0"
        }
        
        if let imageUrl = data.albums,
            
            let url = URL(string: imageUrl) {
            
            dishImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
        }
    }
    
}
