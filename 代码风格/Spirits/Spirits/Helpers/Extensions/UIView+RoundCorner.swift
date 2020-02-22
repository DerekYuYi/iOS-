//
//  UIView+RoundCorner.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/10.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation

extension UIView {
    
    // MARK: - Roundify related
    func roundedCorner() {
        roundedCorner(nil)
    }
    
    func roundedCorner(_ borderColor: UIColor?) {
        roundedCorner(borderColor, 5.0)
    }
    
    func roundedCorner(_ borderColor: UIColor?, _ radius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
        if let borderColor = borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 0.5
        }
    }
}
