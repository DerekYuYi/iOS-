//
//  RYIndicatorViewVisible.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/12.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

private let kRYTagForActivityIndicatorView: Int = 2019

protocol RYIndicatorViewVisible {
    func showIndicatorView(_ isShow: Bool, parentView view: UIView?)
}

extension RYIndicatorViewVisible where Self: UIView {
    
    // MARK: - Add Activity Indicator View
    func showIndicatorView(_ isShow: Bool, parentView view: UIView?) {
        
        var targetParentView: UIView = self
        
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

extension UIView: RYIndicatorViewVisible {}
