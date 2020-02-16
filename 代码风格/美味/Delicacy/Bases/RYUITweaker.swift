//
//  RYUITweaker.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/25.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

class RYUITweaker: NSObject {
    
    // MARK: - Alert
    static func simpleAlert(_ title: String?,
                            message: String?,
                            triggerOK: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let triggerOK = triggerOK {
            let okAction = UIAlertAction(title: "确定", style: .default) { action in
                triggerOK()
            }
            alert.addAction(okAction)
        } else {
            let okAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alert.addAction(okAction)
        }
        alert.show()
    }
    
    static func moreAlert(_ title: String?,
                            message: String?,
                            okString: String?,
                            triggerOK: (() -> Void)? = nil,
                            cancelString: String?,
                            triggerCancel:(() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okString, style: .default) { action in
            if let triggerOK = triggerOK { triggerOK() }
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: cancelString, style: .cancel) { action in
            if let triggerCancel = triggerCancel { triggerCancel() }
        }
        alert.addAction(cancelAction)
        
        alert.show()
    }
    
    // MARK: - Simple constraints
    
    static func addConstraints(_ padding: UIEdgeInsets,
                               for forView: UIView,
                               in superView: UIView?,
                               related relatedView: UIView?) {
        guard let superView = superView, let relatedView = relatedView else {
            return
        }
        
        forView.translatesAutoresizingMaskIntoConstraints = false
    
        let top = NSLayoutConstraint(item: forView,
                                     attribute: NSLayoutConstraint.Attribute.top,
                                     relatedBy: NSLayoutConstraint.Relation.equal,
                                     toItem: relatedView,
                                     attribute: NSLayoutConstraint.Attribute.top,
                                     multiplier: 1.0,
                                     constant: padding.top)
        
        let leading = NSLayoutConstraint(item: forView,
                                         attribute: NSLayoutConstraint.Attribute.leading,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: relatedView,
                                         attribute: NSLayoutConstraint.Attribute.leading,
                                         multiplier: 1.0,
                                         constant: padding.left)
        
        let bottom = NSLayoutConstraint(item: forView,
                                         attribute: NSLayoutConstraint.Attribute.bottom,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: relatedView,
                                         attribute: NSLayoutConstraint.Attribute.bottom,
                                         multiplier: 1.0,
                                         constant: -padding.bottom)
        
        let trailing = NSLayoutConstraint(item: forView,
                                         attribute: NSLayoutConstraint.Attribute.trailing,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: relatedView,
                                         attribute: NSLayoutConstraint.Attribute.trailing,
                                         multiplier: 1.0,
                                         constant: -padding.right)
        
        superView.addConstraints([top, leading, bottom, trailing])
    }
    
    static func addConstraints(for centerOffset: CGPoint,
                               for forView: UIView,
                               in superView: UIView?,
                               related relatedView: UIView?) {
        guard let superView = superView, let relatedView = relatedView else {
            return
        }
        
        forView.translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = NSLayoutConstraint(item: forView,
                                     attribute: NSLayoutConstraint.Attribute.centerX,
                                     relatedBy: NSLayoutConstraint.Relation.equal,
                                     toItem: relatedView,
                                     attribute: NSLayoutConstraint.Attribute.centerX,
                                     multiplier: 1.0,
                                     constant: centerOffset.x)
        
        let centerY = NSLayoutConstraint(item: forView,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: relatedView,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         multiplier: 1.0,
                                         constant: centerOffset.y)
        
        let width = NSLayoutConstraint(item: forView,
                                        attribute: NSLayoutConstraint.Attribute.width,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: nil,
                                        attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                        multiplier: 1.0,
                                        constant: forView.bounds.width)
        
        let height = NSLayoutConstraint(item: forView,
                                          attribute: NSLayoutConstraint.Attribute.height,
                                          relatedBy: NSLayoutConstraint.Relation.equal,
                                          toItem: nil,
                                          attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                          multiplier: 1.0,
                                          constant: forView.bounds.height)
        
        superView.addConstraints([centerX, centerY, width, height])
    }
}
