//
//  RYEditIntroductionCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/16.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYEditIntroductionCell: UITableViewCell {

    @IBOutlet weak var introTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let intro = RYProfileCenter.me.introduction {
            introTextView.text = intro
        }
        
    }

}
