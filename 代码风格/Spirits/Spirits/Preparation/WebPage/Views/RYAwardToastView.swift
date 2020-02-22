//
//  RYAwardToastView.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/11.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYAwardToastView: UIView, RYNibLoadable {
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedCorner()
        backgroundColor = UIColor.black.withAlphaComponent(0.65)
    }
    
    func updateCount(_ count: Int) {
        guard count > 0 else { return }
        countLabel.text = "\(count)"
    }

}
