//
//  RYPreferenceImageCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/8.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Kingfisher

class RYPreferenceImageCell: UITableViewCell {
    
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.roundedCorner(nil, 30.0)
        avatarImageView.backgroundColor = RYColors.yellow_theme
        if let avatarStr = RYProfileCenter.me.avatarUrlString {
            avatarImageView.kf.setImage(with: URL(string: avatarStr), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    func udpate(_ title: String?, image: UIImage?) {
        nickNameLabel.text = title
        if let image = image {
            avatarImageView.image = image
        }
    }
    
}
