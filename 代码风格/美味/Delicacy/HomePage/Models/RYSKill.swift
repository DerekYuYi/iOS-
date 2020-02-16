//
//  RYSKill.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/19.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import Foundation

struct RYSKill {
    var iD: Int?
    var imageUrlString: String?
    var playTime: String?
    var title: String?
    
    init(_ data: [String: Any]?) {
        guard let data = data else { return }
        
        if let idValue = data["id"] as? Int {
            iD = idValue
        }
        
        if let imageUrlStr = data["albums"] as? String {
            imageUrlString = imageUrlStr
        }
        
        if let titleStr = data["title"] as? String {
            title = titleStr
        }
        
        if let playTimeStr = data["play_time"] as? String {
            playTime = playTimeStr
        }
    }
}
