//
//  RYUIViewLoadingProtocol.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/11.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import Foundation
import UIKit

///: - https://gist.github.com/shaps80/dd31ec48afb39e6fe14695c29ff36b77

protocol RYUIViewLoadingProtocol {}

extension UIView: RYUIViewLoadingProtocol {}

extension RYUIViewLoadingProtocol where Self: UIView {
    
//    static func loadFromNib(nibNameOrNil: String? = nil) -> Self {
//    }
}
