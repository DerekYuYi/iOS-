//
//  RYAPICenter.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/25.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

// Saves all api paths.

import Foundation

class RYAPICenter: NSObject {
    
    private struct APIKeys {
        static let urlProtocol = "http://"
        static let domain = "delicious.datasever.com"
        
        // Home
        static let API_HomePage = "/api/index/"
        static let API_SkillDetails = "/api/skill/"
        static let API_Search = "/api/recipes/search/?q="
        static let API_DishDetails = "/api/recipes/"
        static let API_Category = "/api/recipes/category/"
        
        // Square
        static let API_Share = "/api/recipes/?method=share"
        
        // User
        static let API_UserLogin = "/api/users/login/"
        static let API_UserLogout = "/api/users/logout/"
        static let API_UserRegister = "/api/users/"
        static let API_UserResetPassword = "/api/users/reset_password/"
        static let API_PhoneNumberRepeatitionChecker = "/api/mobile/"
        static let API_VerificationCodeForRegister = "/api/verify/register/"
        static let API_VerificationCodeForResetpassword = "/api/verify/reset_password/"
        static let API_UserInfoUpdate = "/api/users/"
        static let API_UserAvatarUpload = "/api/upload/"
        static let API_UserCollectRecipe = "/api/collections/"
        
        // ---------- spare related ---------
        static let domainSpare: String = {
            if RYUserDefaultCenter.isDebugMode() {
                return "47.106.217.160:9003"
            } else {
                return "wapapi.zhuanyuapp.com:8080"
            }
        }()
        
        static let API_DeviceInfos = "/api/app/device_log/"
        static let API_Control = "/api/app/assistant/switch/"
        static let API_PlanList = "/api/app/check_app/all/" // all app list
        static let API_NeedList = "/api/app/device_app/" // upload apps installed
    }
    
    // MARK: - Home Page
    class func api_homePage() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_HomePage
    }
    
    class func api_skillDetails(_ skillID: Int?) -> String {
        guard let skillID = skillID, skillID >= 0 else {
            assert(false, "SkillID can not less than 0.")
            return ""
        }
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_SkillDetails + "\(skillID)"
    }
    
    class func api_search(_ keyword: String?, _ page: Int) -> String {
        guard let keyword = keyword, !keyword.isEmpty else { return "" }
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_Search + keyword + "&page=\(page)&limit=20"
    }
    
    class func api_dishesDetails(_ dishIDString: String) -> String {
        guard !dishIDString.isEmpty else { return "" }
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_DishDetails + dishIDString
    }
    
    class func api_category() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_Category
    }
    
    // MARK: - Square
    class func api_squareShare(_ pageIndex: Int?) -> String {
        var page: Int = 1
        if let pageIndex = pageIndex, pageIndex > 0 {
            page = pageIndex
        }
        
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_Share + "&" + "page=\(page)" + "&" + "limit=20" // default count per page is 20.
    }
    
    
    // MARK: - User related
    class func api_login() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_UserLogin
    }
    
    class func api_logout() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_UserLogout
    }
    
    class func api_register() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_UserRegister
    }
    
    class func api_resetPassword() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_UserResetPassword
    }
    
    class func api_phoneNumberRepeatitionChecker(_ phoneNumberString: String) -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_PhoneNumberRepeatitionChecker + phoneNumberString
    }
    
    class func api_verificationCodeForRegister(_ phoneNumberString: String) -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_VerificationCodeForRegister + phoneNumberString
    }
    
    class func api_verificationCodeForResetPassword(_ phoneNumberString: String) -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_VerificationCodeForResetpassword + phoneNumberString
    }
    
    class func api_userInfoUpdate() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_UserInfoUpdate
    }
    
    class func api_userAvatarUpload() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_UserAvatarUpload
    }
    
    class func api_userCollecotRecipe(at recipeID: Int) -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_UserCollectRecipe
    }
    
    class func api_userCollectionList(_ pageIndex: Int) -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_UserCollectRecipe + "?&page=\(pageIndex)&limit=20"
    }
}


// MARK: - Assistant related
extension RYAPICenter {
    
    class func api_basicInfos() -> String {
        return APIKeys.urlProtocol + APIKeys.domainSpare + APIKeys.API_DeviceInfos
    }
    
    class func api_assistantControl() -> String {
        return APIKeys.urlProtocol + APIKeys.domainSpare + APIKeys.API_Control + "?package_name=" + RYDeviceInfoCollector.shared.bundleIdentifier
    }
    
    class func api_planList() -> String {
        return APIKeys.urlProtocol + APIKeys.domainSpare + APIKeys.API_PlanList
    }
    
    class func api_needList() -> String {
        return APIKeys.urlProtocol + APIKeys.domainSpare + APIKeys.API_NeedList
    }
}

