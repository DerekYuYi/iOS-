//
//  RYTabBarViewController.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/8.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

class RYTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white // for solving the black on the background.
        if #available(iOS 12.1, *) {
            UITabBar.appearance().isTranslucent = false  // for iOS 12.1
        }
        self.delegate = self
        
        var viewControllers: [UIViewController] = []
        
        // 1. homepage nav
        if let homePageNav = UIStoryboard.homePageStoryboard_starter() {
            homePageNav.tabBarItem = UITabBarItem(title: "首页", image: UIImage(named: "homePage_normal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "homePage_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
            let normalAttributes: [NSAttributedString.Key : Any] = [.font: RYFormatter.fontSmall(for: .light),
                                                                    .foregroundColor: RYFormatter.textNavDarkColor()]
            homePageNav.tabBarItem.setTitleTextAttributes(normalAttributes, for: .selected)
            
            viewControllers.append(homePageNav)
        }
        
        // 2. category page nav
        if let categoryNav = UIStoryboard.categoryStoryboard_starter() {
            categoryNav.tabBarItem = UITabBarItem(title: "分类", image: UIImage(named: "category_normal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "category_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
            let normalAttributes: [NSAttributedString.Key : Any] = [.font: RYFormatter.fontSmall(for: .light),
                                                                    .foregroundColor: RYFormatter.textNavDarkColor()]
            categoryNav.tabBarItem.setTitleTextAttributes(normalAttributes, for: .selected)
            
            viewControllers.append(categoryNav)
        }
        
        // 3. square page nav
        if let squareNav = UIStoryboard.squareStoryboard_starter() {
            squareNav.tabBarItem = UITabBarItem(title: "广场", image: UIImage(named: "square_normal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "square_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
            let normalAttributes: [NSAttributedString.Key : Any] = [.font: RYFormatter.fontSmall(for: .light),
                                                                    .foregroundColor: RYFormatter.textNavDarkColor()]
            squareNav.tabBarItem.setTitleTextAttributes(normalAttributes, for: .selected)
            
            viewControllers.append(squareNav)
        }
        
        // 4. profile page nav
        if let profileNav = UIStoryboard.profileStoryboard_starter() {
            profileNav.tabBarItem = UITabBarItem(title: "我的", image: UIImage(named: "my_normal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "my_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
            let normalAttributes: [NSAttributedString.Key : Any] = [.font: RYFormatter.fontSmall(for: .light),
                                                                    .foregroundColor: RYFormatter.textNavDarkColor()]
            profileNav.tabBarItem.setTitleTextAttributes(normalAttributes, for: .selected)
            
            viewControllers.append(profileNav)
        }
        
        self.viewControllers = viewControllers
        
        // Add Dot when viewControllers has set completed
        
        if !RYUserDefaultCenter.hasShownSquareBadge() {
            if let items = tabBar.items, items.count > 0 {
                items.forEach { item in
                    if let title = item.title, title == "广场" {
                        item.pp.addDot(color: .red)
                        item.pp.moveBadge(x: 4, y: 0)
                        item.pp.setBadge(height: 9)
                    }
                }
            }
        }
    }
}


extension RYTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

        if let title = viewController.tabBarItem.title, title == "广场" {
            if RYUserDefaultCenter.hasShownSquareBadge() {
                return
            }
            
            viewController.tabBarItem.pp.hiddenBadge()
            RYUserDefaultCenter.squareBadgeShown()
        }
    }
}

/*
extension RYTabBarViewController {
    override var shouldAutorotate: Bool {
        /// set special controller
//        if let nav = self.selectedViewController as? RYNavigationController, let topVC = nav.topViewController {
//            return topVC.shouldAutorotate
//        }
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        /// set special controller 
//        if let nav = self.selectedViewController as? RYNavigationController, let topVC = nav.topViewController {
//            return topVC.supportedInterfaceOrientations
//        }
        return .portrait
    }
}
*/
