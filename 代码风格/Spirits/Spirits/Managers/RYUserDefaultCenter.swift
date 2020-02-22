//
//  RYUserDefaultCenter.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

enum eRYCoachMarksType: String {
    case typeCell, filterButton, publishButton

    func userDefaultsKey() -> String {
        return "RYUserDefaultCenter_" + self.rawValue
    }
}

class RYUserDefaultCenter: NSObject {
    
    private struct RYUserDefaultKeys {
        static let profileData = "RYUserDefaultCenter_ProfileData"
        static let isDebug = "RYUserDefaultCenter_IsDebug"
        static let webViewCustomUserAgent = "RYUserDefaultCenter_webViewDefaultUserAgent"
        static let webViewUserToken = "RYUserDefaultCenter_webViewUserToken"
        static let awardTaskIsFinished = "RYUserDefaultCenter_awardTaskIsFinished"
        static let dateWhenApplicationWillTerminate = "RYUserDefaultCenter_dateWhenApplicationWillTerminate"
        
        static let index = "RYUserDefaultCenter_indexPath"
        static let coopen = "RYUserDefaultCenter_coopen"
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
    
    /// clear profile info
    static func clearProfileData() {
        if let _ = RYUserDefaultCenter.profileData() {
            UserDefaults.standard.removeObject(forKey: RYUserDefaultKeys.profileData)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// get profile info
    static func profileData() -> RYProfileItem? {
        guard let profileData = UserDefaults.standard.value(forKey: RYUserDefaultKeys.profileData) as? Data else {
            return nil
        }
        return try? PropertyListDecoder().decode(RYProfileItem.self, from: profileData)
    }
    
    
    // MARK: - record IndexPath
    
    static func hasRecordedIndex() -> [Int]? {
        guard let records = UserDefaults.standard.value(forKey: RYUserDefaultKeys.index) as? [Int] else {
            return nil
        }
        return records
    }
    
    static func recordIndex(_ set: [Int]) {
        UserDefaults.standard.set(set, forKey: RYUserDefaultKeys.index)
        UserDefaults.standard.synchronize()
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
    
    // MARK: - Coach marks
    static func hasShownCoachMarks(for type: eRYCoachMarksType) -> Bool {
        return UserDefaults.standard.bool(forKey: type.userDefaultsKey())
    }
    
    static func showCoachMarks(for type: eRYCoachMarksType) {
        UserDefaults.standard.set(true, forKey: type.userDefaultsKey())
        UserDefaults.standard.synchronize()
    }
}

// MARK: - spare related

extension RYUserDefaultCenter {
    
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
    
    static func updateWebViewUserToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: RYUserDefaultKeys.webViewUserToken)
        UserDefaults.standard.synchronize()
    }
    
    static func webViewUserToken() -> String {
        if let string = UserDefaults.standard.value(forKey: RYUserDefaultKeys.webViewUserToken) as? String {
            return string
        }
        return ""
    }
    
    static func finishAwardTask(for type: RYWebPage.eRYWebPageSourceType, _ isFinished: Bool) {
        if var awardTaskData = awardTaskData() {
            awardTaskData.updateValue(isFinished, forKey: type.stringValue())
        } else {
            let awardTaskData = [type.stringValue(): isFinished]
            UserDefaults.standard.set(awardTaskData, forKey: RYUserDefaultKeys.awardTaskIsFinished)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func awardTaskIsFinished(_ type: RYWebPage.eRYWebPageSourceType) -> Bool {
        if let awardTaskData = awardTaskData(),
            let result = awardTaskData[type.stringValue()] {
            return result
        }
        return false
    }
    
    fileprivate static func awardTaskData() -> [String: Bool]? {
        if let awardTaskData = UserDefaults.standard.dictionary(forKey: RYUserDefaultKeys.awardTaskIsFinished) as? [String: Bool] {
            return awardTaskData
        }
        return nil
    }
    
    static func updateDateWhenApplicationWillTerminate(_ date: Date) {
        UserDefaults.standard.set(Double(date.timeIntervalSince1970), forKey: RYUserDefaultKeys.dateWhenApplicationWillTerminate)
        UserDefaults.standard.synchronize()
    }
    
    static func dateWhenApplicationTerminated() -> Date {
        if let interval = UserDefaults.standard.value(forKey: RYUserDefaultKeys.dateWhenApplicationWillTerminate) as? Double {
            return Date(timeIntervalSince1970: TimeInterval(interval))
        }
        return Date()
    }
    
}
