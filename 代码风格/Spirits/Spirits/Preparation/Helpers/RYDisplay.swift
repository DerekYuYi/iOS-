//
//  RYDisplay.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/19.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit


enum eRYInch {
    case inch35, inch4, inch47, inch55, inch58, inch61, inch65
    case unknown
}

class RYDisplay {
    static var width: CGFloat { return UIScreen.main.bounds.size.width }
    static var height: CGFloat { return UIScreen.main.bounds.size.height }
    static var maxLength: CGFloat { return max(width, height) }
    static var minLength: CGFloat { return min(width, height) }
    
    static var phone: Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    
    static var inch: eRYInch {
        guard phone else { return .unknown }
        
        if maxLength < 568 {
            return .inch35
        } else if maxLength == 568 {
            return .inch4
        } else if maxLength == 667 {
            return .inch47
        } else if maxLength == 736 {
            return .inch55
        } else if maxLength == 812 { // x, xs
            return .inch58
        } else if maxLength == 896 && UIScreen.main.scale == 2.0 { // xr
            return .inch61
        } else if maxLength == 896 && UIScreen.main.scale == 3.0 { // xs max
            return .inch65
        }
        
        return .unknown
    }
}
