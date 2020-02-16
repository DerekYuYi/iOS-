//
//  RYDishDetailsBriefCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/24.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYDishDetailsBriefCell: UITableViewCell {

    @IBOutlet weak var dishTitleLabel: UILabel!
    @IBOutlet weak var dishBriefLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(_ data: RYDishDetailsModel) {
        if let dishTitle = data.title {
            dishTitleLabel.text = dishTitle
        }
        
        if let dishBrief = data.introduction {
            dishBriefLabel.text = dishBrief
        }
    }
}
