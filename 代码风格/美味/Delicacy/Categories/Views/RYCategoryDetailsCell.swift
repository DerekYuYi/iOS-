//
//  RYCategoryDetailsCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/5.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Kingfisher

class RYCategoryDetailsCell: UICollectionViewCell {
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var dishTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        contentView.backgroundColor = .red
        contentView.backgroundColor = .white
        dishImageView.backgroundColor = RYColors.gray_imageViewBg
        dishImageView.kf.indicatorType = .activity
    }
    
    func update(_ data: RYCategoryModel) {
        if let name = data.name {
            dishTitleLabel.text = name
        }
        
        if let imageUrl = data.imageUrl,
            let url = URL(string: imageUrl) {
            dishImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
        }
    }
}
