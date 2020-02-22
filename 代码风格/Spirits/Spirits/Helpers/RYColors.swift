//
//  RYColors.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation
import UIKit

struct RYColors {
    
    static func color(from RGB: Int) -> UIColor {
        return UIColor(red: CGFloat((RGB&0xFF0000) >> 16) / 255.0,
                       green: CGFloat((RGB&0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(RGB&0x0000FF) / 255.0,
                       alpha: 1.0)
    }
}

