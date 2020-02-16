//
//  RYDishDetailsImageCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/24.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Kingfisher

class RYDishDetailsImageCell: UITableViewCell {
    
    @IBOutlet weak var headerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let resource = Resource(
        headerImageView.kf.indicatorType = .activity
        headerImageView.backgroundColor = RYColors.gray_imageViewBg
        headerImageView.contentMode = .scaleAspectFill
    }
    
    func update(_ urlString: String?) {
        var urlStr = ""
        if let urlString = urlString {
            urlStr = urlString
        }
        let url = URL(string: urlStr)
        headerImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
    }
    
}
