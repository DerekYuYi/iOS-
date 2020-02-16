//
//  RYViewContrllerTransitioningDelegate.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/3/27.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYViewContrllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
//    var gestureReco = <#value#>
    
    
    // 非交互式动画
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RYViewControllerAnimatedTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RYViewControllerAnimatedTransitioning()
    }
    
    
    /*
    // 交互式动画
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
 
    }
    */
    
}
