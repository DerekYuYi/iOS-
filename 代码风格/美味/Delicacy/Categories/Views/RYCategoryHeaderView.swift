//
//  RYCategoryHeaderView.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/5.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYCategoryHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.backgroundColor = RYColors.gray_mid
    }
    
    func update(_ string: String?) {
        if let string = string {
            headerLabel.text = string
        }
    }
    
}
