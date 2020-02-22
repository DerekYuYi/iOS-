//
//  RYShadowView.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/8.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYShadowView: UIView {
    
    var shadowColor = UIColor.white
    var cornerRadius: CGFloat = 10.0
    
    
    override var bounds: CGRect {
        didSet {
            setupShadow(in: bounds)
        }
    }

    func setupShadow(in rect: CGRect) {
        layer.cornerRadius = cornerRadius
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 8.0
        layer.shadowOpacity = 0.8
        layer.shadowColor = shadowColor.cgColor
        layer.shadowPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func update() {
        layer.shadowColor = shadowColor.cgColor
    }
}
