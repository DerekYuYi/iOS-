//
//  RYColors.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/5.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import Foundation
import UIKit

struct RYColors {
    static let gray_mid = RYColors.color(from: 0xF2F2f2)
    static let gray_imageViewBg = RYColors.color(from: 0xE3E6EF)
    static let yellow_theme = RYColors.color(from: 0xFEE13C)
    static let black_333333 = RYColors.color(from: 0x333333)
    static let black_999999 = RYColors.color(from: 0x999999)
    
    static func color(from RGB: Int) -> UIColor {
        return UIColor(red: CGFloat((RGB&0xFF0000) >> 16) / 255.0,
                       green: CGFloat((RGB&0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(RGB&0x0000FF) / 255.0,
                       alpha: 1.0)
    }
}
