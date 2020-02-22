//
//  RYNewsThreePicsCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/2.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

fileprivate let widthForImageView: CGFloat = 100.0

class RYNewsThreePicsCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var middleImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        leftImageView.backgroundColor = RYColors.color(from: 0xE3E6EF)
        middleImageView.backgroundColor = RYColors.color(from: 0xE3E6EF)
        rightImageView.backgroundColor = RYColors.color(from: 0xE3E6EF)
        
        leftImageView.roundedCorner(nil, 3.0)
        middleImageView.roundedCorner(nil, 3.0)
        rightImageView.roundedCorner(nil, 3.0)
    }
    
    func update(_ data: RYNewsItem) {
        if let title = data.title {
            contentLabel.text = title
        }
        
        if let imageUrls = data.imageUrls, imageUrls.count > 0 {
        
            if let url = URL(string: imageUrls[0]) {
                leftImageView.kf.setImage(with: url, options: [.transition(.fade(0.1))])
            }
            
            if imageUrls.count > 1 {
                if let url = URL(string: imageUrls[1]) {
                    middleImageView.kf.setImage(with: url, options: [.transition(.fade(0.1))])
                }
            }
            
            if imageUrls.count > 2 {
                if let url = URL(string: imageUrls[2]) {
                    rightImageView.kf.setImage(with: url, options: [.transition(.fade(0.1))])
                }
            }
        }
        
        switch data.dtype {
        case .mdadTripleImages:
            sourceLabel.text = "广告"
            commentsLabel.isHidden = true
            updatedTimeLabel.isHidden = true
//            let ratio: CGFloat = 690.0 / 440.0
//            rightImageViewHeightConstraint.constant = widthForRightImageView / ratio
            
        default:
//            let ratio: CGFloat = 4.0 / 3.0
//            rightImageViewHeightConstraint.constant = widthForRightImageView / ratio
            
            if let source = data.source {
                sourceLabel.text = source
            }
            
            if let comments = data.commentCount {
                commentsLabel.isHidden = false
                commentsLabel.text = "\(comments)评论"
            }
            
            if let updatedTimeString = data.date {
                let component = RYFormatter.timeFormatter(from: updatedTimeString, "yyyy-MM-dd HH:mm:ss")
                if let minute = component?.minute {
                    if minute > 0 {
                        updatedTimeLabel.text = "\(minute)分钟前"
                    } else {
                        updatedTimeLabel.text = "刚刚"
                    }
                } else if let hours = component?.hour {
                    updatedTimeLabel.text = "\(hours)小时前"
                }
                updatedTimeLabel.isHidden = false
            }
        }
        
        if let source = data.source {
            sourceLabel.text = source
        }
        
        if let comments = data.commentCount {
            commentsLabel.text = "\(comments)评论"
        }
        
        if let updatedTimeString = data.date {
            let component = RYFormatter.timeFormatter(from: updatedTimeString, "yyyy-MM-dd HH:mm:ss")
            if let minute = component?.minute {
                if minute > 0 {
                    updatedTimeLabel.text = "\(minute)分钟前"
                } else {
                    updatedTimeLabel.text = "刚刚"
                }
            } else if let hours = component?.hour {
                updatedTimeLabel.text = "\(hours)小时前"
            }
        }
    }

}
