//
//  RYPreferencesFooterView.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/12.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

protocol RYPreferencesFooterViewDelegate: NSObjectProtocol {
    func contentButtonTapped()
}

class RYPreferencesFooterView: UIView {

    
    @IBOutlet weak var contentButton: RYBaseButton!
    
    weak var delegate: RYPreferencesFooterViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 11.0, *) {
            backgroundColor = UIColor(named: "Color_f1f8f9")
        } else {
            backgroundColor = RYColors.color(from: 0xF1F8F9)
        }
  
        contentButton.layer.masksToBounds = true
        contentButton.layer.cornerRadius = 5.0
    }
    
    
    @IBAction func contentButtonTapped(_ sender: RYBaseButton) {
        delegate?.contentButtonTapped()
    }
    
}
