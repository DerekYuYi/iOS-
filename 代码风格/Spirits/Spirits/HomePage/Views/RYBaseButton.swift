//
//  RYBaseButton.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/12.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYBaseButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.15) {
                    self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
                }
            } else {
                UIView.animate(withDuration: 0.15) {
                    self.transform = .identity
                }
            }
        }
    }

}
