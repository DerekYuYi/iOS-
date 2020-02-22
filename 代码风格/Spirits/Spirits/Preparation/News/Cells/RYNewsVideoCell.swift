//
//  RYNewsVideoCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/2.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYNewsVideoCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        coverImageView.backgroundColor = RYColors.color(from: 0xE3E6EF)
        coverImageView.roundedCorner(nil, 3.0)
    }
    
    func update(_ data: RYNewsItem) {
        if let title = data.title {
            contentLabel.text = title
        }
        
        if let videoImageString = data.videoImage,
            let url = URL(string: videoImageString) {
            coverImageView.kf.setImage(with: url, options: [.transition(.fade(0.1))])
//                coverImageView.sd_setImage(with: url, completed: nil)
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
        
        if let playCount = data.playCount {
            playCountLabel.text = "\(playCount)次"
        }
        
        if let duration = data.duration {
            let minute = duration / 60
            let seconds = duration % 60
            if minute >= 60 {
                
                let hours = minute / 60
                durationLabel.text = String(format: "%02d", hours) + ":" + String(format: "%02d", minute) + ":" + String(format: "%02d", seconds)
            } else {
                durationLabel.text = String(format: "%02d", minute) + ":" + String(format: "%02d", seconds)
            }
        }
        
        
    }

}
