//
//  RYSettingCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/14.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYSettingCell: UITableViewCell {
    
    @IBOutlet weak var settingTitleLabel: UILabel!
    
    @IBOutlet weak var settingValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        settingTitleLabel.text = "清除缓存"
        settingValueLabel.text = "0.0 M"
    }
    
    func update(_ cacheSize: Double) {
        settingValueLabel.text = "\(cacheSize) M"
    }
    
    func update(_ title: String, detailsTitle: String) {
        settingTitleLabel.text = title
        settingValueLabel.text = detailsTitle
    }

}
