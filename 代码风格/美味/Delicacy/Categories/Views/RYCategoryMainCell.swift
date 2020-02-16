//
//  RYCategoryMainCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/5.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYCategoryMainCell: UITableViewCell {

    @IBOutlet weak var flagView: UIView!
    @IBOutlet weak var categoryTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        flagView.roundedCorner(nil, 1.5)
        showState(isSelected: false)
    }
    
    func showState(isSelected selected: Bool) {
        if selected {
            contentView.backgroundColor = RYFormatter.color(from: 0xF2F2F2)
            flagView.isHidden = false
            categoryTitle.textColor = RYFormatter.textNavDarkColor()
            categoryTitle.font = RYFormatter.fontLarge(for: .medium)
        } else {
            contentView.backgroundColor = .white
            flagView.isHidden = true
            categoryTitle.textColor = RYFormatter.color(from: 0xBEBEBE)
            categoryTitle.font = RYFormatter.fontMedium(for: .medium)
        }
    }
    
    func update(_ title: String?) {
        if let title = title {
            categoryTitle.text = title
        }
    }
    
}
