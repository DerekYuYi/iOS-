//
//  Data+Crypto.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/8.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
    func hexString() -> String {
        
        //        return map {Int($0).hexString}.joined()
        //        return map { String(format: "%2hhx", $0) }.joined()
        //        return map { String($0, radix: 16)}.joined()
        return map { String(format: "%02x", $0) }.joined()
    }
    
    var md5: Data {
        var digest = [UInt8](repeating: 0, count:Int(CC_MD5_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_MD5($0.baseAddress, CC_LONG(count), &digest)
        }
        return Data(digest)
    }
    
    func SHA1() -> Data {
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(count), &digest)
        }
        return Data(digest)
    }
    
    var sha1: Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        withUnsafeBytes({
            _ = CC_SHA1($0.baseAddress, CC_LONG(count), &digest)
        })
        return Data(digest)
    }
    
    /*
     var sha256: Data {
     var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
     withUnsafeBytes({
     _ = CC_SHA256($0.baseAddress, CC_LONG(count), &digest)
     })
     return Data(digest)
     }
     */
}

