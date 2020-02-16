//
//  RYSkillDetailsModel.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/19.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import Foundation

struct RYSkillDetailsModel {
    var iD: Int?
    var videoUrlString: String?
    var title: String?
    var playTime: String?
    
    init(_ data: [String: Any]?) {
        guard let data = data else { return }
        
        if let idValue = data["id"] as? Int {
            iD = idValue
        }
        
        if let imageUrlStr = data["video_url"] as? String {
            videoUrlString = imageUrlStr
        }
        
        if let playTimeValue = data["play_time"] as? String {
            playTime = playTimeValue
        }
        
        if let titleValue = data["title"] as? String {
            title = titleValue
        }
        
    }
}
