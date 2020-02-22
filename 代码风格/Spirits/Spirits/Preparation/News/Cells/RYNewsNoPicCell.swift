//
//  RYNewsNoPicCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/2.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYNewsNoPicCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(_ data: RYNewsItem) {
        if let title = data.title {
            contentLabel.text = title
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
