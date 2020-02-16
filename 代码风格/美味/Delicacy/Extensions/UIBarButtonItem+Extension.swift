//
//  UIBarButtonItem+Extension.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/9.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import Foundation
import UIKit


extension UIBarButtonItem {
    func leftCustomizeView(_ title: String, backgroundColor: UIColor?) {
        let bgWidth: CGFloat = 48
        let bgHeight: CGFloat = 44
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: bgWidth, height: bgHeight))
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.tintColor = .clear
        titleLabel.textColor = RYFormatter.textNavDarkColor()
        titleLabel.font = RYFormatter.fontGiant(for: .medium)
        let titleHeight: CGFloat = 34
        titleLabel.frame = CGRect(x: 0, y: (bgHeight-titleHeight)/2.0, width: bgWidth, height: titleHeight)
//        titleLabel.backgroundColor = backgroundColor
        titleLabel.backgroundColor = .clear
        bgView.backgroundColor = .clear
        bgView.tintColor = .clear
        bgView.addSubview(titleLabel)
        self.customView = bgView
        self.tintColor = .red
    }
}


