//
//  UIView+Extension.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/21.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import Foundation
import UIKit

private let kRYTagForActivityIndicatorView: Int = 2018

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
    
    // MARK: - Nib related
    
    
    
    // MARK: - Animations
    func shake(for keyPath: String?, duration: CFTimeInterval? = nil, repeatCount: Float? = nil) {
        guard let keypath = keyPath else { return }
        
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
        self.layer.add(shakeAnimation, forKey: nil)
    }
    
    
    // MARK: - Add Activity Indicator View
    func showIndicatorView(_ isShow: Bool, parentView view: UIView? = nil) {
        var targetParentView = self
        
        if let parentView = view {
            targetParentView = parentView
        }
        
        if isShow {
            if let indicatorView = targetParentView.viewWithTag(kRYTagForActivityIndicatorView) as? UIActivityIndicatorView {
                indicatorView.startAnimating()
            } else {
                let indicatorView = UIActivityIndicatorView(style: .white)
                indicatorView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                indicatorView.tag = kRYTagForActivityIndicatorView
                targetParentView.addSubview(indicatorView)
                indicatorView.center = self.center
                indicatorView.startAnimating()
            }
        } else {
            if let indicatorView = targetParentView.viewWithTag(kRYTagForActivityIndicatorView) as? UIActivityIndicatorView {
                indicatorView.stopAnimating()
                indicatorView.removeFromSuperview()
            }
        }
    }
}


