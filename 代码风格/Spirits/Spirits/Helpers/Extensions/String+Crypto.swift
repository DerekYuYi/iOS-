//
//  String+Crypto.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/8.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation
import CommonCrypto

enum eRYHMACAlgorithm: Int32 {
    case md5, sha1, sha224, sha256, sha384, sha512
    
    
    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result = 0
        
        switch self {
        case .md5:
            result = kCCHmacAlgMD5
            
        case .sha1:
            result = kCCHmacAlgSHA1
            
        case .sha224:
            result = kCCHmacAlgSHA224
            
        case .sha256:
            result = kCCHmacAlgSHA256
            
        case .sha384:
            result = kCCHmacAlgSHA384
            
        case .sha512:
            result = kCCHmacAlgSHA512
        }
        
        return CCHmacAlgorithm(result)
    }
    
    
    func digestLength() -> Int {
        var result: CInt = 0
        
        switch self {
        case .md5:
            result = CC_MD5_DIGEST_LENGTH
            
        case .sha1:
            result = CC_SHA1_DIGEST_LENGTH
            
        case .sha224:
            result = CC_SHA224_DIGEST_LENGTH
            
        case .sha256:
            result = CC_SHA256_DIGEST_LENGTH
            
        case .sha384:
            result = CC_SHA384_DIGEST_LENGTH
            
        case .sha512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    // MARK: - HMAC Algorithm
    
    func hmac(_ algorithm: eRYHMACAlgorithm, key: String) -> String {
        guard let cKey = key.cString(using: .utf8) else {
            assert(false, "Error! Key for algorithm is nil.")
            return ""
        }
        
        guard let cData = self.cString(using: .utf8) else {
            assert(false, "Error! Body for algorithm is nil.")
            return ""
        }
        
        var result = [CUnsignedChar](repeating: 0, count: algorithm.digestLength())
        
        CCHmac(algorithm.toCCHmacAlgorithm(), cKey, strlen(cKey), cData, strlen(cData), &result)
        
        let hmacData = Data(bytes: result, count: algorithm.digestLength())
        
        let hmacBase64String = hmacData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength76Characters)
        return hmacBase64String
    }
    
    // MARK: -  MD5, SHA1, SHA256, ...
    func hexString() -> String {
        guard let data = self.data(using: .utf8) else {
            assert(false, "\(#function) error occurred.")
            return ""
        }
        return data.hexString()
    }
    
    func SHA1() -> String {
        guard let data = self.data(using: .utf8) else {
            assert(false, "\(#function) error occurred.")
            return ""
        }
        return data.sha1.hexString()
    }
    
    func MD5() -> String {
        guard let data = self.data(using: .utf8) else {
            assert(false, "\(#function) error occurred.")
            return ""
        }
        return data.md5.hexString()
    }
    
    /// Return a random string by given capacity.
    static func randomString(from capacity: UInt) -> String {
        let characterPool = "abcdefghijklmnopqrstuvwxyz0123456789"
        guard capacity <= characterPool.count else {
            assertionFailure("\(#function) Error Occured! capacity can not greater than \(characterPool.count)")
            return ""
        }
        
        var randomString = ""
        for _ in 0..<capacity {
            let randomIndex = Int(arc4random_uniform(UInt32(characterPool.count)))
            let randomChar = characterPool[randomIndex]
            randomString.append(randomChar)
        }
        return randomString
    }
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
}

