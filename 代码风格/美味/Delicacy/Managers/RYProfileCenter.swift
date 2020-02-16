//
//  RYProfileCenter.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/8.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

//class RYProfileCenter: NSObject {
//
//}

struct RYProfileCenter {
    
    static var me = RYProfileCenter()
    
    // MARK: - User Properties
    var userID: Int? {
        get {
            if let profile = profileData { return profile.userID }
            return nil
        }
        set {
            
        }
    }
    
    var phoneNumber: String? {
        get {
            if let profile = profileData { return profile.phoneNumber }
            return nil
        }
        
        set {
        }
    }
    
    var nickName: String? {
        get {
            if let profile = profileData { return profile.nickName }
            return nil
        }
        
        set(newValue) {
            if var profile = profileData {
                profile.nickName = newValue
                profileData = profile
            }
        }
    }
    
    var sex: String? {
        get {
            if let profile = profileData {
                return profile.sexString
            }
            return nil
        }
        
        set(newValue) {
            if var profile = profileData {
                profile.sexString = newValue
                profileData = profile
            }
        }
    }
    
    var avatarUrlString: String? {
        get {
            if let profile = profileData {
                return profile.avatarUrlString
            }
            return nil
        }
        
        set(newValue) {
            if var profile = profileData {
                profile.avatarUrlString = newValue
                profileData = profile
            }
        }
    }
    
    var introduction: String? {
        get {
            if let profile = profileData { return profile.introduction }
            return nil
        }
        
        set(newValue) {
            if var profile = profileData {
                profile.introduction = newValue
                profileData = profile
            }
        }
    }
    
    var isLogined: Bool {
        if let _ = profileData { return true }
        return false
    }
    
    var profileData: RYProfileItem? {
        get {
            return RYUserDefaultCenter.profileData()
        }
        set(newValue) {
            RYUserDefaultCenter.updateProfileData(newValue)
        }
    }
    
    func logout() {
        RYUserDefaultCenter.clearProfileData()
    }
}

struct RYProfileItem: Codable {
    var userID: Int?
    var phoneNumber: String?
    var avatarUrlString: String?
    var nickName: String?
    var sexString: String?
    var introduction: String?
    
    init(_ data: [String: Any]?) {
        guard let data = data else { return }
        
        if let userid = data["uid"] as? Int, userid >= 0 {
            userID = userid
        }
        
        if let phoneNum = data["mobile"] as? String, !phoneNum.isEmpty {
            phoneNumber = phoneNum
        }
        
        if let avatarUrlStr = data["avatar"] as? String, !avatarUrlStr.isEmpty {
            avatarUrlString = avatarUrlStr
        }
        
        if let nickNameString = data["nick"] as? String, !nickNameString.isEmpty  {
            nickName = nickNameString
        }
        
        if let sexCount = data["gender"] as? Int, sexCount >= 0 {
            if sexCount == 0 {
                sexString = "男"
            } else {
                sexString = "女"
            }
        }
        
        if let intro = data["introduction"] as? String, !intro.isEmpty  {
            introduction = intro
        }
    }
}
