//
//  RYDataManager.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/15.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Kingfisher

class RYDataManager: NSObject {
    
    // MARK: - Disk cache data
    class func cacheDataSize(_ calculatedSuccessfullyHandler: @escaping ((Double) -> Void)) {
        ImageCache.default.calculateDiskCacheSize { cacheSize in
            var totalCacheSize: UInt = cacheSize
            
            DispatchQueue.global().async {
                if let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last {
                    let fileInfo = try? FileManager.default.attributesOfItem(atPath: cachePath)
                    if let fileInfo = fileInfo,
                        let otherCacheSize = fileInfo[FileAttributeKey.size] as? UInt {
                        totalCacheSize += otherCacheSize
                    }
                    calculatedSuccessfullyHandler(Double(totalCacheSize / (1024*1024)))
                }
            }
        }
    }
    
    class func clearDiskCacheData(_ completedHandler: (() -> Void)? = nil) {
        // clear kingfisher disk cache
        ImageCache.default.clearDiskCache {
            DispatchQueue.global().async {
                if let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last {
                    try? FileManager.default.removeItem(atPath: cachePath)
                    if let completedHandler = completedHandler {
                        completedHandler()
                    }
                }
            }
        }
    }
    
    // MARK: - Cookie
    class func getCookie() {
        let tempCookie = HTTPCookieStorage.shared
        debugPrint(tempCookie)
        if let tempCookies = tempCookie.cookies {
            for item in tempCookies {
                debugPrint(item)
            }
        }
    }
    
    class func constructLoginCookie(for url: URL) {
        let cookieStorage = HTTPCookieStorage.shared
        
        var willSetProperties: [HTTPCookiePropertyKey: Any]?
        
        if let cookies = cookieStorage.cookies,
            let sessionIDString = RYUserDefaultCenter.archiveredSessionID() {
            for cookie in cookies {
                willSetProperties = cookie.properties
                willSetProperties?.updateValue(sessionIDString, forKey: HTTPCookiePropertyKey.value)
            }
            if let willSetProperties = willSetProperties, let willSetCookie = HTTPCookie(properties: willSetProperties) {
                cookieStorage.setCookies([willSetCookie], for: url, mainDocumentURL: nil)
            }
        }
    }
}

