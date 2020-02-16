//
//  RYPreferenceCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/8.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

private let kRYWidthForAvatar: CGFloat = 60.0

class RYPreferenceCell: UITableViewCell {

    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var devidedView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        devidedView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func update(_ title: String, _ value: String,  _ hasSeperator: Bool) {
        nickNameLabel.text = title
        valueLabel.text = value
        if hasSeperator {
            devidedView.isHidden = false
        } else {
            devidedView.isHidden = true
        }
    }
    
    

    
}
