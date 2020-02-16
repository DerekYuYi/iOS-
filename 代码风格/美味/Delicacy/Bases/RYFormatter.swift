//
//  RYFormatter.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/25.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

/// Color related
private let kRYRGB_Taupe = 0x454E50
private let kRYRGB_TextDark = 0x999999
private let kRYRGB_TextGray = 0x666666
private let kRYRGB_TextNavDark = 0x333333
private let kRYRGB_Brown = 0x666699
private let kRYRGB_BGGray = 0xEEEEEE
private let kRYRGB_BGLightGray = 0xF7F7F7
private let kRYRGB_BorderGray = 0xEDEDED
private let kRYRGB_MiddleGray = 0xCFCFCF
private let kRYRGB_MilkWhite = 0x000000 // black color
private let kRYRGB_shallowGray = 0xF1F1F2
private let kRYRGB_shallowYellow = 0xFEE13C
/// Font related
private let kRYFontSizeGiant: CGFloat = 24
private let kRYFontSizeHugeMedium: CGFloat = 22
private let kRYFontSizeHuge: CGFloat = 20
private let kRYFontSizeLarge: CGFloat = 16
private let kRYFontSizeMedium: CGFloat = 14
private let kRYFontSizeSmall: CGFloat = 12
private let kRYFontSizeTint: CGFloat = 10

class RYFormatter: NSObject {
    
    // MARK: - Colors
    static func colorRandom() -> UIColor {
        let red: Int = Int(arc4random_uniform(256) % 256)
        let green: Int = Int(arc4random_uniform(256) % 256)
        let blue: Int = Int(arc4random_uniform(256) % 256)
        return color(from: red*256*256 + green*256 + blue)
    }
    
    static func color(from RGB: Int) -> UIColor {
        return UIColor(red: CGFloat((RGB&0xFF0000) >> 16) / 255.0,
                green: CGFloat((RGB&0x00FF00) >> 8) / 255.0,
                blue: CGFloat(RGB&0x0000FF) / 255.0,
                alpha: 1.0)
    }
    
    static func taupeColor() -> UIColor {
        return color(from: kRYRGB_Taupe)
    }
    
    static func textDarkColor() -> UIColor {
        return color(from: kRYRGB_TextDark)
    }
    
    static func textGrayColor() -> UIColor {
        return color(from: kRYRGB_TextGray)
    }
    
    static func textNavDarkColor() -> UIColor {
        return color(from: kRYRGB_TextNavDark)
    }
    
    static func textBrownColor() -> UIColor {
        return color(from: kRYRGB_Brown)
    }
    
    static func bgGrayColor() -> UIColor {
        return color(from: kRYRGB_BGGray)
    }
    
    static func bgLightGrayColor() -> UIColor {
        return color(from: kRYRGB_BGLightGray)
    }
    
    static func borderGrayColor() -> UIColor {
        return color(from: kRYRGB_BorderGray)
    }
    
    static func middleGrayColor() -> UIColor {
        return color(from: kRYRGB_MiddleGray)
    }
    
    static func milkWhiteColor() -> UIColor {
        return color(from: kRYRGB_MilkWhite)
    }
    
    static func shallowGrayColor() -> UIColor {
        return color(from: kRYRGB_shallowGray)
    }
    
    static func shallowYellowColor() -> UIColor {
        return color(from: kRYRGB_shallowYellow)
    }
    
}


enum ERYFontStyle {
    case light, medium, regular, bold
}

extension RYFormatter {
    
    static func matchFontName(from fontStyle: ERYFontStyle) -> String {
        var name = ""
        switch fontStyle {
        case .light:
            name = "PingFangSC-Light"
            
        case .medium:
            name = "PingFangSC-Medium"
            
        case .regular:
            name = "PingFangSC-Regular"
            
        case .bold:
            name = "PingFangSC-Semibold"
        }
        return name
    }
    
    /// The font name is `style` and the size is 24.0.
    static func fontGiant(for style: ERYFontStyle) -> UIFont {
        if let font = UIFont(name: matchFontName(from: style), size: kRYFontSizeGiant) {
            return font
        }
        return UIFont.systemFont(ofSize: kRYFontSizeGiant)
    }
    
    /// The font name is `style` and the size is 22.0.
    static func fontHugeMedium(for style: ERYFontStyle) -> UIFont {
        if let font = UIFont(name: matchFontName(from: style), size: kRYFontSizeHugeMedium) {
            return font
        }
        return UIFont.systemFont(ofSize: kRYFontSizeHugeMedium)
    }
    
    /// The font name is `style` and the size is 20.0.
    static func fontHuge(for style: ERYFontStyle) -> UIFont {
        if let font = UIFont(name: matchFontName(from: style), size: kRYFontSizeHuge) {
            return font
        }
        return UIFont.systemFont(ofSize: kRYFontSizeHuge)
    }
    
    /// The font name is `style` and the size is 16.0.
    static func fontLarge(for style: ERYFontStyle) -> UIFont {
        if let font = UIFont(name: matchFontName(from: style), size: kRYFontSizeLarge) {
            return font
        }
        return UIFont.systemFont(ofSize: kRYFontSizeLarge)
    }
    
    /// The font name is `style` and the size is 14.0.
    static func fontMedium(for style: ERYFontStyle) -> UIFont {
        if let font = UIFont(name: matchFontName(from: style), size: kRYFontSizeMedium) {
            return font
        }
        return UIFont.systemFont(ofSize: kRYFontSizeMedium)
    }
    
    /// The font name is `style` and the size is 12.0.
    static func fontSmall(for style: ERYFontStyle) -> UIFont {
        if let font = UIFont(name: matchFontName(from: style), size: kRYFontSizeSmall) {
            return font
        }
        return UIFont.systemFont(ofSize: kRYFontSizeSmall)
    }
    
    /// The font name is `style` and the size is 10.0.
    static func fontTint(for style: ERYFontStyle) -> UIFont {
        if let font = UIFont(name: matchFontName(from: style), size: kRYFontSizeTint) {
            return font
        }
        return UIFont.systemFont(ofSize: kRYFontSizeTint)
    }
    
    /// The font name is `style` and the size is `size`.
    static func font(for style: ERYFontStyle, fontSize size: CGFloat) -> UIFont {
        if let font = UIFont(name: matchFontName(from: style), size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
    
    // MARK: - navigation bar height and status bar height
    static func navigationBarPlusStatusBarHeight(for vc: Any?) -> CGFloat {
        // viewcontroller
        if let vc = vc as? UIViewController, let nav = vc.navigationController {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let navBarHeight = nav.navigationBar.bounds.height
            return statusBarHeight + navBarHeight
        }
        
        // navigationcontroller
        if let vc = vc as? UINavigationController {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let navBarHeight = vc.navigationBar.bounds.height
            return statusBarHeight + navBarHeight
        }
        
        // contants
        if isiPhoneXSeries() {
            return 88.0
        } else {
            return 64.0 // 20 + 56
        }
    
    }
    
    static func statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    
    static func tabBarHeight() -> CGFloat {
        var previousHeight: CGFloat = 49.0
        if isiPhoneXSeries() {
            let homeIndicatorHeight: CGFloat = 34.0
            previousHeight += homeIndicatorHeight
        }
        return previousHeight
    }
    
    static func isiPhoneXSeries() -> Bool {
        return UIScreen.main.bounds.height >= 812.0 ? true : false
    }
    
    // MARK: - Simple valid phone number
    /// Validates phone number
    static func isValidPhoneNumber(for numberString: String?) -> Bool {
        guard let numberString = numberString, numberString.count == 11 else {
            return false
        }
        
        let mobile = "^1((3[0-9]|4[57]|5[0-35-9]|7[0678]|8[0-9])\\d{8}$)"
        let CM = "(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
        let CU = "(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
        let CT = "(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
        
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@", mobile)
        let regextestcm = NSPredicate(format: "SELF MATCHES %@", CM)
        let regextestcu = NSPredicate(format: "SELF MATCHES %@", CU)
        let regextestct = NSPredicate(format: "SELF MATCHES %@", CT)
        
        if ((regextestmobile.evaluate(with: numberString) == true)
            || (regextestcm.evaluate(with: numberString) == true)
            || (regextestct.evaluate(with: numberString) == true)
            || (regextestcu.evaluate(with: numberString) == true)) {
            return true
        } else {
            return false
        }
    }
}

