//
//  UIAlertController+RYShow.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/25.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    private struct AssociatedKeys {
        static var alertWindowKey = "UIAlertController_alertWindow"
    }
    
    var alertWindow: UIWindow? {
        get {
            if let window = objc_getAssociatedObject(self, &AssociatedKeys.alertWindowKey) as? UIWindow {
                return window
            }
            return nil
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.alertWindowKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIAlertController {
    
    func show() {
        presentAlert(animated: true)
    }
    
    func presentAlert(animated flag: Bool, completion: (() -> Void)? = nil) {
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.rootViewController = UIViewController()
        alertWindow?.windowLevel = .alert + 1
        alertWindow?.makeKeyAndVisible()
        alertWindow?.rootViewController?.present(self, animated: true, completion: completion)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        alertWindow?.isHidden = true
        alertWindow = nil
    }
}
