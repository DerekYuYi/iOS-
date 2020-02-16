//
//  RYNavigationController.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/26.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

@objc protocol RYNavigationStyleTransparent: NSObjectProtocol {
}

@objc protocol RYNavigationStyleSemiTransparent: NSObjectProtocol {
}

@objc protocol RYNavigationStyleShadow: NSObjectProtocol {
}

@objc protocol RYNavigationStyleColorful: NSObjectProtocol {
}

@objc protocol RYNavigationStyleCustomize: NSObjectProtocol {
}


class RYNavigationController: UINavigationController {
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYNavigationController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYNavigationController()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup_RYNavigationController()
    }
    
    private func setup_RYNavigationController() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.delegate = self
        self.navigationBar.barTintColor = .white
        
        RYNavigationController.navigationBarTextBlackStyle(for: navigationBar)
        
        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = false
        }
        
        let backIndicatorImage = UIImage(named: "back_nav_white")
        self.navigationBar.backIndicatorImage = backIndicatorImage
        self.navigationBar.backIndicatorTransitionMaskImage = backIndicatorImage
    }
}

// MARK: - Public Interface

extension RYNavigationController {
    static func setShadowStyle(for bar: UINavigationBar) {
        eRYBarStyle.transparentWithShadow.adapt(for: bar)
    }
}

extension RYNavigationController {
    
    /// setup gradient image from gradientlayer and default direction is vertical.
    private static func gradientImage(from startColor: UIColor, to endColor: UIColor, in rect: CGRect) -> UIImage {
        if rect == CGRect(x: 0, y: 0, width: 0, height: 0) {
            return UIImage()
        }
        
        let size = rect.size
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        layer.colors = [startColor.cgColor, endColor.cgColor]
//        layer.type = .axial
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0.0, y: 1.0) // vertical
        
        var image = UIImage()
        
        UIGraphicsBeginImageContext(size)
        
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            if let currentImage = UIGraphicsGetImageFromCurrentImageContext() {
                image = currentImage
            }
            UIGraphicsEndImageContext()
        }
        return image
    }
}

// MARK: - UINavigationControllerDelegate
extension RYNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        // to prevent multiple hits on 'back' button
        enableUserInteraction(false)
        
        // set navigationbar style
        setNavStyle(for: viewController)
        
        // change nav style when pop gesture determines
        guard let transitionCoordinator = navigationController.topViewController?.transitionCoordinator else { return }
        transitionCoordinator.notifyWhenInteractionChanges { context in
            if context.isCancelled {
                self.setNavStyle(for: context.viewController(forKey: .from))
            } else {
                self.setNavStyle(for: context.viewController(forKey: .to))
            }
        }
        
        // NOTE: this solves the issue that sometimes
        //  when popToRootViewController:Animated is envoked, viewWillAppear is not called, and the tabbar won't show properly
        //sss// At this moment, only care about the 5 root view controllers
//        viewController.viewWillAppear(animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        // to prevent multiple hits on 'back' button
        enableUserInteraction(true)
        
        // This gives some view transparent navigation bar
        setNavStyle(for: viewController)
    }
}


extension RYNavigationController {
    private func setNavStyle(for viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        if vc.conforms(to: RYNavigationStyleTransparent.self) {
            eRYBarStyle.transparent.adapt(for: navigationBar)
            
        } else if vc.conforms(to: RYNavigationStyleSemiTransparent.self) {
            
        } else if vc.conforms(to: RYNavigationStyleShadow.self) {
            eRYBarStyle.transparentWithShadow.adapt(for: navigationBar)
            
        } else if vc.conforms(to: RYNavigationStyleColorful.self) {
            eRYBarStyle.transparentWithColorful.adapt(for: navigationBar)
            
        } else if vc.conforms(to: RYNavigationStyleCustomize.self) {
            // do nothing
            
        } else {
            RYNavigationController.navigationBarTextBlackStyle(for: navigationBar)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
    }
    
    private func enableUserInteraction(_ isEnable: Bool) {
        guard let gestureRecognizers = navigationBar.gestureRecognizers, gestureRecognizers.count > 0 else { return }
        
        for gesture in gestureRecognizers {
            if gesture.isMember(of: UITapGestureRecognizer.self) {
                gesture.isEnabled = isEnable
            }
        }
    }
}


/// When you're in a navigation controller that will not get called. The navigation controller's preferredStatusBarStyle will be called. 
extension RYNavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}


// MARK: - NavigationBar Styles
extension RYNavigationController {
    private enum eRYBarStyle {
        case transparent, transparentWithShadow, transparentWithColorful
        
        func adapt(for bar: UINavigationBar?) {
            guard let bar = bar else { return }
            
            switch self {
            case .transparent:
                bar.setBackgroundImage(UIImage.image(from: .clear), for: .default)
                bar.shadowImage = UIImage() // to remove shadow
                RYNavigationController.navigationBarTextBlackStyle(for: bar)
                
            case .transparentWithShadow:
                
                let startColor = UIColor.black.withAlphaComponent(0.7)
                let endColor = UIColor.black.withAlphaComponent(0.0)
                let navAndStatusBarRect = CGRect(x: 0, y: 0, width: bar.bounds.width, height: RYFormatter.navigationBarPlusStatusBarHeight(for: self))
                // NOTE: There are some exceptions about UI if you don't draw dradient image in asynchronous.
                DispatchQueue.main.async {
//                    if let gradientImage = gradientLayer.gradientImage() {
//                        bar.setBackgroundImage(gradientImage, for: .default)
//                    }
                    let graImage = RYNavigationController.gradientImage(from: startColor, to: endColor, in: navAndStatusBarRect)
                    bar.setBackgroundImage(graImage, for: .default)
                }
                
//                bar.setBackgroundImage(UIImage(named: "gradient_navigation"), for: .default)
                bar.shadowImage = UIImage() // to remove shadow
                RYNavigationController.navigationBarTextWhiteStyle(for: bar)
                
            case .transparentWithColorful:
                let colorfulImage = UIImage()
                bar.setBackgroundImage(colorfulImage, for: .default)
                bar.shadowImage = UIImage() // to remove shadow
                RYNavigationController.navigationBarTextBlackStyle(for: bar)
            }
        }
    }
    
    private static func navigationBarTextWhiteStyle(for navigationBar: UINavigationBar) {
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,
                                                  .font: RYFormatter.font(for: .bold, fontSize: 17.0)]
    }
    
    private static func navigationBarTextBlackStyle(for navigationBar: UINavigationBar) {
        navigationBar.tintColor = .black
        navigationBar.titleTextAttributes = [.foregroundColor: RYFormatter.textNavDarkColor(),
                                                  .font: RYFormatter.font(for: .bold, fontSize: 17.0)]
    }
}

/*
extension RYNavigationController {
    override var shouldAutorotate: Bool {
        /// set special controller
//        if let topVC = self.topViewController {
//            return topVC.shouldAutorotate
//        }
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        /// set special controller 
//        if let topVC = self.topViewController {
//            return topVC.supportedInterfaceOrientations
//        }
        return .portrait
    }
}
*/
