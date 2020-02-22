//
//  RYEncryptHelper.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/6/26.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation


struct RYEncryptHelper {
    
    static let rsaPublicString = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlR1cBTQdeGN1moaLJN3q\nyPBut7OF6L8DrxI/g2UPsF1Ok4F4UpTJV0lUkJLHzgCVCii2OLIconmDOb+9KD4R\n0rgcRHPLTE1PCifGMUoPqwVuusWVFGoc8cNkVwRBoYWMQfFEZXWpb30fRFootSYW\nrNMTbvvKxxZxvBwWIkeQQDM+WI3hz8CjeuNs4rH4jGg5YnpYp0Km2wUTygiO136d\n/9wFOxrS4YX5w1AhJtZ1I0E+YSY4XODq/OKvD045BSYRvB271vvjoYS8lKYfgaK6\nk1uMiJeDZQ+EOIEBNZn/eRPzSR120Z+ktuwAd9vTwQZFZk1oVcxy4ebVfgCsbLww\nCQIDAQAB\n-----END PUBLIC KEY-----"
    
    /// Generates key for aes.
    static func generateKeysForAES() -> String {
        
        let totalCount = 32
        
        let bundleId = RYDeviceInfoCollector.shared.bundleIdentifier
        let idfa = RYDeviceInfoCollector.shared.identifierForAdvertising
        
        guard bundleId.count > 8 else { return "" }
        guard idfa.count > totalCount else { return "" }
        
        if bundleId.count >= 32 {
            return String(bundleId.prefix(32))
        } else {
            let needPlaceCount = totalCount - bundleId.count
            let startIndex = idfa.index(idfa.startIndex, offsetBy: 8)
//            let needPlaceString = String(idfa.prefix(needPlaceCount))
            let endIndex = idfa.index(startIndex, offsetBy: needPlaceCount)
            let range = startIndex..<endIndex
            let needPlaceString = String(idfa[range])
            
            return bundleId + needPlaceString
        }
    }
    
    static func encryptRSA(for string: String) -> String {
        guard !string.isEmpty else {
            return ""
        }
        
        guard let rsaEncryptedBase64String = RSA.encryptString(string, publicKey: rsaPublicString), !rsaEncryptedBase64String.isEmpty else {
            return ""
        }
        
        return rsaEncryptedBase64String
    }
    
    
    
}
