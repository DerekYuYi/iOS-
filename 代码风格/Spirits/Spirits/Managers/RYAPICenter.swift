//
//  RYAPICenter.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/12.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYAPICenter: NSObject {
    
    private struct APIKeys {
        static let urlProtocol = "http://"
        static let urlProtocolEnhanced = "https://"
        static let domain = "miaozhao.datasever.com"
    
        static let API_register = "/api/users/"
        static let API_login = "/api/login/"
        
        static let API_favorite = "/api/coups/" // & + 'collection/'
        static let API_cancelFavorite = "/api/coups/" // & + 'cancel_collection/'
        static let API_types = "/api/classes/"
        static let API_publish = "/api/coups/"
        static let API_list = "/api/coups/?classification="
        
        // ---------- spare related ---------
        
        static let domainSpare: String = {
            if RYUserDefaultCenter.isDebugMode() {
                return "47.106.217.160:9004"
            } else {
                return "appapi.zhuanyuapp.com"
            }
        }()
        
        static let API_Control = "/api/assistant/switch/"
        static let API_prepareList = "/api/device/"
    }
    
    /// register api
    static func api_regiter() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_register
    }
    
    /// login api
    static func api_login() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_login
    }
    
    /// api that collect a related type
    static func api_favorite(at favoriteID: Int) -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_favorite + "\(favoriteID)" + "/collection/"
    }
    
    /// api that collect a related type
    static func api_cancelFavorite(at favoriteID: Int) -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_cancelFavorite + "\(favoriteID)" + "/cancel_collection/"
    }
    
    /// api that returns all types
    static func api_types() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_types
    }
    
    /// publish api
    static func api_publish() -> String {
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_publish
    }
    
    /// favorites list api
    static func api_favoritesList(for type: Int, pageNumber: Int) -> String {
        guard type >= 0, pageNumber > 0 else { return "" }
        guard let userID = RYProfileCenter.me.userID else { return "" }
        
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_list + "\(type)" + "&collection=\(userID)" + "&page_num=\(pageNumber)" + "&page_size=20"
    }
    
    /// types list api
    static func api_typesList(for type: Int, pageNumber: Int) -> String {
        
        guard type >= 0, pageNumber > 0 else { return "" }
        
        var typeString = "\(type)"
        if type == 1 { typeString = "" }
        
        return APIKeys.urlProtocol + APIKeys.domain + APIKeys.API_list + typeString + "&page_num=\(pageNumber)" + "&page_size=20"
    }
}


extension RYAPICenter {
    
    static func api_assistantControl() -> String {
        return (RYUserDefaultCenter.isDebugMode() ? APIKeys.urlProtocol : APIKeys.urlProtocolEnhanced) + APIKeys.domainSpare + APIKeys.API_Control + "?package_name=" + RYDeviceInfoCollector.shared.bundleIdentifier + "&assistant_version=\(RYDeviceInfoCollector.shared.appVersion)"
    }

    static func api_prepareList() -> String {
         return (RYUserDefaultCenter.isDebugMode() ? APIKeys.urlProtocol : APIKeys.urlProtocolEnhanced) + APIKeys.domainSpare + APIKeys.API_prepareList
    }
}

