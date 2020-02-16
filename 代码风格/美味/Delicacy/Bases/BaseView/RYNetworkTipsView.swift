//
//  RYNetworkTipsView.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/22.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

typealias RYNetworkTipsViewClosure = () -> Void

class RYNetworkTipsView: UIView {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var retryButton: UIButton!
    var tapClosure: RYNetworkTipsViewClosure?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        retryButton.roundedCorner()
        statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
//        retryButton.backgroundColor = RYColors.yellow_theme.withAlphaComponent(0.5)
        retryButton.showsTouchWhenHighlighted = true
    }
    
    @IBAction func retryButtonTapped(_ sender: UIButton) {
        if let tapClosure = tapClosure {
            tapClosure()
        }
    }
    
}
