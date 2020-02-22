//
//  RYGradientView.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYGradientView: UIView {

    var startColor: UIColor = .white
    var endColor: UIColor = .white
    
    
    override var bounds: CGRect {
        didSet {
            setupGradient()
        }
    }
    
    private var gradientLayer: CAGradientLayer? = nil
    
//    lazy var gradientLayer: CAGradientLayer = {
//
//        let graLayer = CAGradientLayer()
//
//        graLayer.colors = [startColor.cgColor, endColor.cgColor]
//
//        graLayer.startPoint = CGPoint(x: 0, y: 0)
//        graLayer.endPoint = CGPoint(x: 0, y: 1)
//        graLayer.type = .axial
//        return graLayer
//    }()
    
    private func setupGradient() {
//        clearGradientLayer()
        
        let gradientLayer = CAGradientLayer()
        self.gradientLayer = gradientLayer
        
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.type = .axial

        gradientLayer.frame = bounds
        
        // set for background
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
//    func clearGradientLayer() {
//        gradientLayer?.removeFromSuperlayer()
//        gradientLayer = nil
//    }
    
    func update() {
        guard let gradientLayer = gradientLayer else {
            return
        }
        
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
    }
}
