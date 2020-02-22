//
//  RYLevelButton.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/15.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYLevelButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            
            let highlightColor = UIColor.black.withAlphaComponent(0.2)
            let defaultColor: UIColor
            if #available(iOS 13.0, *) {
                defaultColor = UIColor.systemBackground
            } else {
                defaultColor = .white
            }
            
            if isHighlighted {
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    self.backgroundColor = self.isHighlighted ? highlightColor : defaultColor
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    self.transform = .identity
                    self.backgroundColor = self.isHighlighted ? highlightColor : defaultColor
                }
            }
        }
    }

}
