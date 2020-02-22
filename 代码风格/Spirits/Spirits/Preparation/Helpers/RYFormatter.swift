//
//  RYFormatter.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/3/26.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

struct RYFormatter {
    
    /// Returns navigation bar height and status bar height of the specified view controller.
    /// - Parameter vc: A view controller instance that contains target bars.
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
            return 64.0
        }
    }
    
    private static func isiPhoneXSeries() -> Bool {
        return UIScreen.main.bounds.height >= 812.0 ? true : false
    }
    
    static func statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    /// Retrieves time format from given date and date format.
    /// - Parameters:
    ///   - dateString: A string indicates the current timestamp.
    ///   - dateFormatString: A string indicates the format to be coverted. such as 'yyyy-MM-dd HH-mm', 'yyyy-MM-dd HH:mm:ss'.
    /// - Returns: An optional instance of DateComponents.
    static func timeFormatter(from dateString: String, _ dateFormatString: String) -> DateComponents? {
        guard !dateString.isEmpty else { return nil }
        let currentDate = Date()
        let formatter = DateFormatter()
        if !dateFormatString.isEmpty {
            formatter.dateFormat = dateFormatString
        }
        
        guard let targetDate = formatter.date(from: dateString) else { return nil }
        
        let calendar = Calendar.current
        return calendar.dateComponents([.day, .month, .year, .hour, .minute, .second],
                                       from: targetDate,
                                       to: currentDate)
    }
    
    /// Adds custom constraints for view.
    /// - Parameters:
    ///   - centerOffset: offset from superview's center'offset.
    ///   - forView: target view.
    ///   - superView: superview.
    ///   - relatedView: referential view.
    static func addConstraints(for centerOffset: CGPoint,
                               for forView: UIView,
                               in superView: UIView?,
                               related relatedView: UIView?) {
        guard let superView = superView, let relatedView = relatedView else {
            return
        }
        
        forView.translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = NSLayoutConstraint(item: forView,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: relatedView,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         multiplier: 1.0,
                                         constant: centerOffset.x)
        
        let centerY = NSLayoutConstraint(item: forView,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: relatedView,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         multiplier: 1.0,
                                         constant: centerOffset.y)
        
        let width = NSLayoutConstraint(item: forView,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: nil,
                                       attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                       multiplier: 1.0,
                                       constant: forView.bounds.width)
        
        let height = NSLayoutConstraint(item: forView,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: nil,
                                        attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                        multiplier: 1.0,
                                        constant: forView.bounds.height)
        
        superView.addConstraints([centerX, centerY, width, height])
    }
}
