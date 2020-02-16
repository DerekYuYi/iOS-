//
//  RYBanner.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/19.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import Foundation

struct RYBanner {
    var iD: Int?
    var imageUrlString: String?
//    var linkUrlString: String?
//    var title: String?
    
    init(_ data: [String: Any]?) {
        guard let data = data else { return }
        
        if let idValue = data["id"] as? Int {
            iD = idValue
        }
        
        if let imageUrlStr = data["image"] as? String {
            imageUrlString = imageUrlStr
        }
    }
}
