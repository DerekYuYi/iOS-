//
//  RYBasedViewController.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import Toast_Swift

enum eRYLoadingViewCenterOffset {
    case top(Float)
    case left(Float)
    case bottom(Float)
    case right(Float)
}

class RYBasedViewController: UIViewController {
    
    private struct Constants {
        static let loadingViewTag: Int = 408
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    /// Control RYActivityIndicatorView is loading or not.
    func showLoadingView(_ isShow: Bool, offset: eRYLoadingViewCenterOffset? = nil) {
        
        if isShow {
            if let loadingView = view.viewWithTag(Constants.loadingViewTag) as? RYActivityIndicatorView {
                loadingView.isHidden = false
                loadingView.startAnimating()
                return
            }
            
            let loadingView = RYActivityIndicatorView()
            loadingView.numberOfCircles = 3
            loadingView.delegate = self
            loadingView.tag = Constants.loadingViewTag
            loadingView.isHidden = false
            view.addSubview(loadingView)
            view.bringSubviewToFront(loadingView)
            
            var centerX: CGFloat = view.center.x
            var centerY: CGFloat = view.center.y
            
            if let offset = offset {
                switch offset {
                case .left(let left):
                    centerX += CGFloat(left)
                    
                case .right(let right):
                    centerX += CGFloat(right)
                    
                case .top(let top):
                    centerY += CGFloat(top)
                    
                case .bottom(let bottom):
                    centerY += CGFloat(bottom)
                }
                
                loadingView.center = CGPoint(x: centerX, y: centerY)
                
            } else {
                loadingView.center = view.center
            }
            
            loadingView.startAnimating()
            
        } else {
            if let loadingView = view.viewWithTag(Constants.loadingViewTag) as? RYActivityIndicatorView {
                loadingView.isHidden = true
                loadingView.delegate = nil
                loadingView.stopAnimating()
                loadingView.removeFromSuperview()
                return
            }
        }
    }
}

// MARK: - RYActivityIndicatorViewDelegate

extension RYBasedViewController: RYActivityIndicatorViewDelegate {
    func activityIndicatorView(_ activityIndicatorView: RYActivityIndicatorView, circleBackgroundColorAt index: NSInteger) -> UIColor {
        switch index {
        case 0:
            return UIColor.orange
            
        case 1:
            return RYColors.color(from: 0x26B762)
            
        case 2:
            return RYColors.color(from: 0x2F80ED)
            
        default:
            return .green
        }
    }
}
