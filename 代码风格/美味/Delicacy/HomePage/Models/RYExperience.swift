//
//  RYExperience.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/19.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import Foundation


struct RYExperience {
    var iD: Int?
    var imageUrlString: String?
    var intro: String?
    
    var isLike: Bool?
    var isCollection: Bool?
    var likeCount: Int?
    
    var cook: RYProfileItem?
    
    init(_ data: [String: Any]?) {
        guard let data = data else { return }
        
        if let idValue = data["id"] as? Int {
            iD = idValue
        }
        
        if let imageUrlStr = data["albums"] as? String {
            imageUrlString = imageUrlStr
        }
        
        if let titleStr = data["introduction"] as? String {
            intro = titleStr
        }
        
        if let hasCollection = data["is_collection"] as? Bool {
            self.isCollection = hasCollection
        }
        
        if let isLike = data["is_like"] as? Bool {
            self.isLike = isLike
        }
        
        if let likeCount = data["like_count"] as? Int {
            self.likeCount = likeCount
        }
        
        if let cookDict = data["user"] as? [String: Any], cookDict.count > 0 {
            self.cook = RYProfileItem(cookDict)
        }
        
    }
}
