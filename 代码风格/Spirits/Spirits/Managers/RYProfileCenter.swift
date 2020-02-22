//
//  RYProfileCenter.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYProfileCenter: NSObject {
    
    static var me = RYProfileCenter()
    
    // MARK: - User infomations
    
    var userID: Int? {
        get {
            if let profile = profileData { return profile.userID }
            return nil
        }
        set {
            
        }
    }
    
//    var phoneNumber: String? {
//        get {
//            if let profile = profileData { return profile.phoneNumber }
//            return nil
//        }
//
//        set {
//        }
//    }
    
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
    
    var token: String? {
        get {
            if let profile = profileData { return profile.token }
            return nil
        }
        
        set(newValue) {
            if var profile = profileData {
                profile.token = newValue
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

// MARK: - Profile info item

struct RYProfileItem: Codable {
    var userID: Int?
    var nickName: String?
    var token: String?
    
    
    init(_ data: [String: Any]?) {
        guard let data = data else { return }
        
        if let userid = data["id"] as? Int, userid >= 0 {
            userID = userid
        }
        
        if let nickNameString = data["username"] as? String, !nickNameString.isEmpty  {
            nickName = nickNameString
        }
        
        if let token = data["token"] as? String, !token.isEmpty  {
            self.token = token
        }
        
    }
}
