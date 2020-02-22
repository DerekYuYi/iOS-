//
//  RYShakeable.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/10.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit


protocol RYShakeable {
    func shake(for keyPath: String?, duration: CFTimeInterval?, repeatCount: Float?)
}

extension RYShakeable where Self: UIView {
    // MARK: - Animations
    func shake(for keyPath: String?, duration: CFTimeInterval? = nil, repeatCount: Float? = nil) {
        guard let keypath = keyPath else { return }
        
        if let _ = layer.animation(forKey: keypath) {
            layer.removeAnimation(forKey: keypath)
        }
        
        var durationTime = 0.18
        if let duration = duration {
            durationTime = duration
        }
        
        var repeatCountNumber: Float = 3
        if let repeatCount = repeatCount {
            repeatCountNumber = repeatCount
        }
        
        let shakeAnimation = CABasicAnimation(keyPath: keypath)
        shakeAnimation.fromValue = self.center.x - 8
        shakeAnimation.toValue = self.center.x + 8
        shakeAnimation.duration = durationTime
        shakeAnimation.repeatCount = repeatCountNumber
        shakeAnimation.autoreverses = true
        shakeAnimation.isRemovedOnCompletion = true
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        self.layer.add(shakeAnimation, forKey: keypath)
    }
}

extension UIView: RYShakeable {}
