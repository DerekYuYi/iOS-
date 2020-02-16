//
//  RYEditSexCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/16.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYEditSexCell: UITableViewCell {

    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var flagLabel: UILabel!
    @IBOutlet weak var devidedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sexLabel.text = RYProfileCenter.me.sex
        devidedView.backgroundColor = .groupTableViewBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flagLabel.roundedCorner(nil, flagLabel.bounds.height/2.0)
    }
    
    func update(_ sexString: String, indexPathRow: Int, isHiddenFlag isHidden: Bool) {
        sexLabel.text = sexString
        if indexPathRow == 0 {
            devidedView.isHidden = false
        } else {
            devidedView.isHidden = true
        }
        flagLabel.isHidden = isHidden
    }
    
}
