//
//  RYUserDefaultCenter.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/25.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

class RYUserDefaultCenter: NSObject {
    
    private struct RYUserDefaultKeys {
        static let historyKeywords = "RYUserDefaultCenter_HistoryKeywords"
        static let hotKeywords = "RYUserDefaultCenter_HotKeywords"
        static let profileData = "RYUserDefaultCenter_ProfileData"
        static let sessionID = "RYUserDefaultCenter_SessionID"
        static let hotReceiptBadge = "RYUserDefaultCenter_HotReceiptBadge"
        static let lastestReceiptBadge = "RYUserDefaultCenter_LastestReceiptBadge"
        static let squareBadge = "RYUserDefaultCenter_SquareBadge"
        static let favoriteBadge = "RYUserDefaultCenter_FavoriteBadge"
        
        static let isDebug = "RYUserDefaultCenter_IsDebug"
        static let webViewCustomUserAgent = "RYUserDefaultCenter_webViewDefaultUserAgent"
        
        static let coopen = "RYUserDefaultCenter_coopen"
    }
    
    // MARK: - History Keywords
    static func searchHistoricalKeywords() -> [String]? {
        if let keywords = UserDefaults.standard.array(forKey: RYUserDefaultKeys.historyKeywords) as? [String], keywords.count > 0 {
            return keywords
        }
        return nil
    }
    
    static func saveHistoricalKeyword(_ keyword: String) {
        guard !keyword.isEmpty else { return }
        
        var helperArray: [String] = []
        if let keywords = UserDefaults.standard.array(forKey: RYUserDefaultKeys.historyKeywords) as? [String], keywords.count > 0 {
            helperArray.append(contentsOf: keywords)
        }
        
        if !helperArray.contains(keyword) {
            helperArray.insert(keyword, at: 0)
        }
        
        UserDefaults.standard.set(helperArray, forKey: RYUserDefaultKeys.historyKeywords)
        UserDefaults.standard.synchronize()
    }
    
    static func clearHistoricalKeywords() {
        if var keywords = UserDefaults.standard.array(forKey: RYUserDefaultKeys.historyKeywords) as? [String], keywords.count > 0 {
            keywords.removeAll()
        }
        UserDefaults.standard.removeObject(forKey: RYUserDefaultKeys.historyKeywords)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Hot Keywords
    static func searchHotKeywords() -> [String] {
        if let keywords = UserDefaults.standard.array(forKey: RYUserDefaultKeys.hotKeywords) as? [String], keywords.count > 0 {
            return keywords
        }
        return ["早餐", "粥", "排骨", "红烧肉", "茄子", "沙拉", "虾", "养颜", "甜品", "家常菜", "川菜", "辣"]
    }
    
    static func saveHotKeywords(_ keywords: [String]) {
        guard keywords.count > 0 else { return }
        
        UserDefaults.standard.set(keywords, forKey: RYUserDefaultKeys.hotKeywords)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Profile data
    // NOTE: The struct RYProfileItem must conform Codable protocol.
    
    /// update profile data
    static func updateProfileData(_ profile: RYProfileItem?) {
        guard let profile = profile else { return }
        // clear
        RYUserDefaultCenter.clearProfileData()
        
        // add again
        UserDefaults.standard.set(try? PropertyListEncoder().encode(profile), forKey: RYUserDefaultKeys.profileData)
        UserDefaults.standard.synchronize()
    }
    
    /// clear profile data
    static func clearProfileData() {
        if let _ = RYUserDefaultCenter.profileData() {
            UserDefaults.standard.removeObject(forKey: RYUserDefaultKeys.profileData)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// get profile data
    static func profileData() -> RYProfileItem? {
        guard let profileData = UserDefaults.standard.value(forKey: RYUserDefaultKeys.profileData) as? Data else {
            return nil
        }
        return try? PropertyListDecoder().decode(RYProfileItem.self, from: profileData)
    }
    
    
    // MARK: - SessionID
    static func archiveredSessionID() -> String? {
        guard let sessionIDData = UserDefaults.standard.value(forKey: RYUserDefaultKeys.sessionID) as? Data, let sessionIDString = NSKeyedUnarchiver.unarchiveObject(with: sessionIDData) as? String else {
            return nil
        }
        return sessionIDString
    }
    
    static func archiverSessionID(_ string: String?) {
        // guard
        guard let string = string else {
            return
        }
        
        // clear
        RYUserDefaultCenter.clearArchiveredSessionID()
        
        // update
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: string), forKey: RYUserDefaultKeys.sessionID)
        UserDefaults.standard.synchronize()
    }
    
    static func clearArchiveredSessionID() {
        if let _ = archiveredSessionID() {
            UserDefaults.standard.removeObject(forKey: RYUserDefaultKeys.sessionID)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Red Points Badge
    static func lastestReceiptBadgeShown() {
        recordUserDefaults(for: RYUserDefaultKeys.lastestReceiptBadge)
    }
    
    static func hasShownLastestReceiptBadge() -> Bool {
        return UserDefaults.standard.bool(forKey: RYUserDefaultKeys.lastestReceiptBadge)
    }
    
    static func hotReceiptBadgeShown() {
        recordUserDefaults(for: RYUserDefaultKeys.hotReceiptBadge)
    }
    
    static func hasShownHotReceiptBadge() -> Bool {
        return UserDefaults.standard.bool(forKey: RYUserDefaultKeys.hotReceiptBadge)
    }
    
    static func squareBadgeShown() {
        recordUserDefaults(for: RYUserDefaultKeys.squareBadge)
    }
    
    static func hasShownSquareBadge() -> Bool {
        return UserDefaults.standard.bool(forKey: RYUserDefaultKeys.squareBadge)
    }
    
    static func favoriteBadgeShown() {
        recordUserDefaults(for: RYUserDefaultKeys.favoriteBadge)
    }
    
    static func hasShownFavoriteBadge() -> Bool {
        return UserDefaults.standard.bool(forKey: RYUserDefaultKeys.favoriteBadge)
    }
    
    
    // MARK: - Debug or Production Parameters
    
    static func isDebugMode() -> Bool {
        return UserDefaults.standard.bool(forKey: RYUserDefaultKeys.isDebug)
    }
    
    static func setDebugMode(_ bool: Bool) {
        UserDefaults.standard.set(bool, forKey: RYUserDefaultKeys.isDebug)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Default webview User-Agent
    
    static func assembleWebViewUserAgent(_ customUserAgent: String) {
        UserDefaults.standard.set(customUserAgent, forKey: RYUserDefaultKeys.webViewCustomUserAgent)
        UserDefaults.standard.synchronize()
    }
    
    static func webViewCustomUserAgent() -> String {
        if let string = UserDefaults.standard.value(forKey: RYUserDefaultKeys.webViewCustomUserAgent) as? String {
            return string
        }
        return ""
    }
    
    // MARK: - coopen image
    static func cacheCoopenImageData(for adItem: RYAdvertisement) {
        let data = NSKeyedArchiver.archivedData(withRootObject: adItem)
        UserDefaults.standard.set(data, forKey: RYUserDefaultKeys.coopen)
        UserDefaults.standard.synchronize()
    }
    
    static func cachedCoopenImageData() -> RYAdvertisement? {
        if let data = UserDefaults.standard.data(forKey: RYUserDefaultKeys.coopen),
            let adItem = NSKeyedUnarchiver.unarchiveObject(with: data) as? RYAdvertisement {
            return adItem
        }
        return nil
    }
    
    static func clearCoopenImageData() {
        if let _ = UserDefaults.standard.data(forKey: RYUserDefaultKeys.coopen) {
            UserDefaults.standard.removeObject(forKey: RYUserDefaultKeys.coopen)
        }
        UserDefaults.standard.synchronize()
    }
    
    
    // MARK: - Helpers
    
    private static func recordUserDefaults(for key: String) {
        guard !key.isEmpty else {
            fatalError("UserDefaults.standard can't set value for empty key.")
        }
        
        UserDefaults.standard.set(true, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    /*
    private static func accessUserDefaults(for key: String) {
        
    }
    */
    
    
}
