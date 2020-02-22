//
//  RYNavigationController.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/3/27.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            navigationBar.tintColor = .black
            navigationBar.barTintColor = .systemBackground
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel,
            .font: UIFont(name: "PingFangSC-Medium", size: 18.0)!]
        } else {
            view.backgroundColor = .white
            navigationBar.tintColor = .black
            navigationBar.barTintColor = .white
            navigationBar.titleTextAttributes = [.foregroundColor: RYColors.color(from: 0x333333),
            .font: UIFont(name: "PingFangSC-Medium", size: 18.0)!]
        }
        
        let arrowLeftImage = UIImage(named: "arrow_left")?.withRenderingMode(.alwaysOriginal)
        
//        arrowLeftImage = UIImage(named: "back_gray")?.withRenderingMode(.alwaysOriginal)
        
        navigationBar.backIndicatorImage = arrowLeftImage
        navigationBar.backIndicatorTransitionMaskImage = arrowLeftImage
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }

}
