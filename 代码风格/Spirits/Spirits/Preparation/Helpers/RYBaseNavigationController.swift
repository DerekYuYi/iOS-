//
//  RYBaseNavigationController.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYBaseNavigationController: UINavigationController {
    
    private var duringPushAnimation = false
    
    // MARK: - Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYBaseNavigationController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYBaseNavigationController()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    private func setup_RYBaseNavigationController() {
        delegate = self
    }
    
    // MARK: - Deinit
    
    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        navigationBar.tintColor = .black
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [.foregroundColor: RYColors.color(from: 0x333333),
                                             .font: UIFont(name: "PingFangSC-Medium", size: 18.0)!]
        
        let arrowLeftImage = UIImage(named: "back_gray")?.withRenderingMode(.alwaysOriginal)
        
        navigationBar.backIndicatorImage = arrowLeftImage
        navigationBar.backIndicatorTransitionMaskImage = arrowLeftImage
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true
        super.pushViewController(viewController, animated: animated)
    }
}

// MARK: - UINavigationControllerDelegate

extension RYBaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let _ = navigationController as? RYBaseNavigationController else { return }
        duringPushAnimation = false
    }
}

// MARK: - UIGestureRecognizerDelegate

extension RYBaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true // default value
        }
        
        // Disable pop gesture in two situations:
        // 1> when the pop animation is in progress
        // 2> when user swipes quickly a coupe of times and animations don't have time to be performed.
        return viewControllers.count > 1 && duringPushAnimation == false
    }
}
