//
//  RYViewControllerAnimatedTransitioning.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/3/27.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    /*
    let targetEdge: UIRectEdge
    
    init(_ targetEdge: UIRectEdge) {
        self.targetEdge = targetEdge
    }
    */
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        let isPresenting = (toVC.presentingViewController == fromVC)
        
        let fromFrame = transitionContext.initialFrame(for: fromVC)
        let toFrame = transitionContext.finalFrame(for: toVC)
        
        /*
        let offset: CGVector
        switch self.targetEdge {
        case .top: offset = CGVector(dx: 0, dy: 1)
        case .bottom: offset = CGVector(dx: 0, dy: -1)
        case .left: offset = CGVector(dx: 1, dy: 0)
        case .right: offset = CGVector(dx: -1, dy: 0)
            
        default:
            fatalError("targetEdge must be one of UIRectEdgeTop, UIRectEdgeLeft, UIRectEdgeBottom or UIRectEdgeRight")
        }
        */
      
        if isPresenting {
            fromView.frame = fromFrame
            toView.frame = toFrame.offsetBy(dx: toFrame.size.width, dy: 0)
            containerView.addSubview(toView)
        } else {
            fromView.frame = fromFrame
            toView.frame = toFrame
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            if isPresenting {
                toView.frame = toFrame
            } else {
                fromView.frame = fromFrame.offsetBy(dx: fromFrame.size.width, dy: 0)
            }
        }) { _ in
            let wasCancelled = transitionContext.transitionWasCancelled
            
            // remove toView
            if wasCancelled {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!wasCancelled)
        }
        
    }
    
    
}
