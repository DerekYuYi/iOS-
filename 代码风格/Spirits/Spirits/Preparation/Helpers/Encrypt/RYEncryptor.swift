//
//  RYEncryptor.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/6/25.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation
import CryptoSwift

struct RYEncryptor {
    
    static func encryptedAES(_ key: String, iV: String, willBeEncryptedString: String) -> String? {
        guard !key.isEmpty, !iV.isEmpty, !willBeEncryptedString.isEmpty else {
            return nil
        }
        
        let aes = try? AES(key: Array(key.utf8), blockMode: CBC(iv: Array(iV.utf8)), padding: .zeroPadding)
        if let aes = aes {
            
            let result = try? aes.encrypt(willBeEncryptedString.bytes)
            if let result = result {
                guard let base64String = result.toBase64() else { return nil }
                return base64String
            }
        }
        
        return nil
    }
    
    
    static func encryptedAES(_ key: String, iV: String, willBeEncryptedData: Data) -> String? {
        guard !key.isEmpty, !iV.isEmpty else {
            return nil
        }

        
        let aes = try? AES(key: Array(key.utf8), blockMode: CBC(iv: Array(iV.utf8)), padding: .zeroPadding)
        if let aes = aes {
            
            let result = try? aes.encrypt(Array(willBeEncryptedData))
            if let result = result {
                guard let base64String = result.toBase64() else { return nil }
                return base64String
            }
        }
        
        return nil
    }
}
