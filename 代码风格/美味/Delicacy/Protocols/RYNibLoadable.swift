//
//  RYNibLoadable.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/5/21.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation

protocol RYNibLoadable { }


extension RYNibLoadable where Self: UIView {
    
    static func loadFromNib() -> Self? {
        let classFullName = String(describing: self)
        if let nibName = classFullName.components(separatedBy: ".").last {
            return loadFromNib(nibName)
        }
        return nil
    }
    
    static func loadFromNib(_ nibName: String) -> Self? {
        if let objects = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil) {
            for object in objects {
                if let object = object as? Self {
                    return object
                }
            }
        }
        return nil
    }
}
