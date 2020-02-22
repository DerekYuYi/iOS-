//
//  RYNewsTitleCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/10.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYNewsTitleCell: UITableViewCell {
    
    @IBOutlet weak var flagView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        flagView.roundedCorner(nil, 2.0)
    }
    
}
