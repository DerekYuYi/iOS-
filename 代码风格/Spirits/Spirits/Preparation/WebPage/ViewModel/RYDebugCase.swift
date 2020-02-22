//
//  RYDebugCase.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/3.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

/// A view model used to show debug information and applied to the view controller.
class RYDebugCase: NSObject {
    
    private struct Constants {
        static let tagForTipsLabel: Int = 801
        static let minimumPressDuration: TimeInterval = 15
    }
    
    private weak var hookingViewController: UIViewController?
    
    /// Show in debug. You can ignore it when you are product.
    private lazy var alertViewController = UIAlertController(title: "Choose Channel", message: nil, preferredStyle: .actionSheet)
    
    init(_ viewController: UIViewController) {
        hookingViewController = viewController
        super.init()
        setup()
    }
    
    func setup() {
        guard let hookVC = hookingViewController else { return }
        
        if let navbar = hookVC.navigationController?.navigationBar {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction))
            longPressGesture.minimumPressDuration = Constants.minimumPressDuration
            navbar.addGestureRecognizer(longPressGesture)
        }
    }
    
    @objc private func longPressGestureAction(_ sender: UILongPressGestureRecognizer) {
        guard let hookVC = hookingViewController else { return }
        guard !alertViewController.isBeingPresented else { return }
        
        alertViewController = UIAlertController(title: "Choose Channel", message: nil, preferredStyle: .actionSheet)
        
        let productAction = UIAlertAction(title: "Production", style: .default) {[weak self] action in
            guard let strongSelf = self else { return }
            
            // set value
            if RYUserDefaultCenter.isDebugMode() {
                RYUserDefaultCenter.setDebugMode(false)
            }
            
            // show tips
            DispatchQueue.main.async {
                strongSelf.tips(for: "已切换为正式", duration: 1.2)
            }
        }
        
        let debugAction = UIAlertAction(title: "Debug", style: .default) {[weak self] action in
            guard let strongSelf = self else { return }
            
            if !RYUserDefaultCenter.isDebugMode() {
                RYUserDefaultCenter.setDebugMode(true)
            }
            
            // show tips
            DispatchQueue.main.async {
                strongSelf.tips(for: "已切换为测试", duration: 1.2)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) {[weak self] action in
            guard let strongSelf = self else { return }
            strongSelf.alertViewController.dismiss(animated: true, completion: nil)
        }
        
        alertViewController.addAction(productAction)
        alertViewController.addAction(debugAction)
        alertViewController.addAction(cancelAction)
        
        hookVC.present(alertViewController, animated: true, completion: nil)
    }
    
    private func tips(for text: String, duration: TimeInterval) {
        
        let tipLabel = tipsLabel(text)
        tipLabel.alpha = 0.0
        
        UIView.animate(withDuration: duration, animations: {
            tipLabel.isHidden = false
            tipLabel.alpha = 1.0
        }, completion: { _ in
            tipLabel.isHidden = true
            tipLabel.removeFromSuperview()
            self.alertViewController.dismiss(animated: true, completion: nil)
        })
    }
    
    private func tipsLabel(_ text: String) -> UILabel {
        guard let hookVC = hookingViewController else { return UILabel() }
        
        if let label = hookVC.view.viewWithTag(Constants.tagForTipsLabel) as? UILabel {
            label.isHidden = true
            return label
        } else {
            let tipLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 50))
            tipLabel.tag = Constants.tagForTipsLabel
            tipLabel.text = text
            tipLabel.backgroundColor = UIColor.groupTableViewBackground
            tipLabel.textColor = .black
            tipLabel.font = UIFont(name: "PingFangSC-Semibold", size: 20.0)
            tipLabel.textAlignment = .center
            tipLabel.layer.masksToBounds = true
            tipLabel.layer.cornerRadius = 5.0
            tipLabel.numberOfLines = 0
            
            tipLabel.isHidden = true
            hookVC.view.addSubview(tipLabel)
            tipLabel.center = hookVC.view.center
            hookVC.view.bringSubviewToFront(tipLabel)
            
            return tipLabel
        }
    }

}
