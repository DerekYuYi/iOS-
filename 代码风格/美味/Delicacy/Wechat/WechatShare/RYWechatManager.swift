//
//  RYWechatManager.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/4/22.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation

enum eRYWechatShareObjectType {
    case webpage, image
}

class RYWechatManager: NSObject {
    
    static let imageDataKey = "imageData"
    static let webPageUrlKey = "share_webPageUrl"
    static let titleKey = "share_title"
    static let descriptionKey = "share_description"
    static let thumbImageDataKey = "thumbImageData"
    static let thumbImageUrlStringKey = "share_thumbImageUrl"
    
    /// Share to wechat.
    /// - Parameters:
    ///   - scene: WXScene type.
    ///   - objectType: An enum indicates which object type will to be shared.
    ///   - objectData: A Dictionary type and it contains stable keys. There are keys:
    ///
    ///           ["imageData": Data,
    ///     "share_webPageUrl": String,
    ///          "share_title": String,
    ///    "share_description": String,
    ///       "thumbImageData": Data,
    ///  "share_thumbImageUrl": String]
    ///
    static func shareToWechat(for scene: WXScene, objectType: eRYWechatShareObjectType, objectData: [String: Any]) {
        
        /*
         1. 在 webpage didFinish 的时候发送微信安装情况
         2. 在 监听到 JS 发送 微信分享时, 调用该方法
         */
        
        guard isWechatInstalled() else {
            return
        }
        
        // Object setup
        var object: AnyObject? = nil
        
        switch objectType {
        case .image:
            let imageObject = WXImageObject()
            if let objectData = objectData[imageDataKey] as? Data {
                imageObject.imageData = objectData
            }
            object = imageObject
            
        case .webpage:
            let webpageObject = WXWebpageObject()
            if let string = objectData[webPageUrlKey] as? String, !string.isEmpty {
                webpageObject.webpageUrl = string
            }
            object = webpageObject
        }
        
        let message = WXMediaMessage()
        
        // add thumb image
        
        // the priority of show thumb image is: thumbImageDataKey -> thumbImageUrlStringKey(network) -> local
        if let thumbData = objectData[thumbImageDataKey] as? Data {
            message.thumbData = thumbData
            
        } else if let thumbImageUrlString = objectData[thumbImageUrlStringKey] as? String,
            let thumbImageUrl = URL(string: thumbImageUrlString) {
            
            do {
                let thumbImageData = try Data(contentsOf: thumbImageUrl)
                message.thumbData = thumbImageData
            } catch {
                // use local image
                if let imageIcon = UIImage(named: "icon-20") {
                    message.thumbData = imageIcon.pngData()
                }
            }
            
        } else {
            if let imageIcon = UIImage(named: "icon-20") {
                message.thumbData = imageIcon.pngData()
            }
        }
        
        // add title
        if let title = objectData[titleKey] as? String, !title.isEmpty {
            message.title = title
        }
        
        // add description
        if let description = objectData[descriptionKey] as? String, !description.isEmpty {
            message.description = description
        }
        
        message.mediaObject = object
        
        // SendMessageToWXReq setup
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        WXApi.send(req)
    }
    
    /// Logins wechat.
    static func wechatLogin() {
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo" // access user infomations
        req.state = "123"
        WXApi.send(req)
    }
    
    static func isWechatInstalled() -> Bool {
        return WXApi.isWXAppInstalled()
    }
    
    /// Receive and handle response that wechat authorization for login.
    /// - Parameters:
    ///   - resp: A instance of `SendAuthResp`.
    ///   - appID: A string that generated automatically when create apps under wechat open platform.
    ///   - appSecret: A string that generated automatically when create apps under wechat open platform.
    @objc static func wechatLoginAuthDidResponded(_ resp: SendAuthResp?, appID: String, appSecret: String) {
        guard let resp = resp, !appID.isEmpty, !appSecret.isEmpty else { return }
        
        // code is available when errCode is 0.
        if resp.errCode == 0 {
            if let code = resp.code {
                
                // get code and request with code
                let api_accessToken = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(appID)&secret=\(appSecret)&code=\(code)&grant_type=authorization_code"
                
                RYLaunchHelper.request(api_accessToken,
                                       method: .get,
                                       type: .tripartite,
                                       successHandler: { dict in
                                        if let openID = dict["openid"] as? String,
                                            let accessToken = dict["access_token"] as? String, !openID.isEmpty, !accessToken.isEmpty {
                                            
                                            let userInfoApi = "https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openID)"
                                            RYLaunchHelper.request(userInfoApi, method: .get, type: .tripartite, successHandler: { dict in
                                                
                                                var helperDict = dict
                                                
                                                helperDict.updateValue(accessToken, forKey: "access_token")
                                                
                                                // post notification for successful state of wechat logined.
                                                NotificationCenter.default.post(name: NSNotification.Name(nRYNotificationForWechatLoginSuccessfully), object: nil, userInfo: helperDict)
                                            }, failureHandler: { error in
                                                debugPrint("Request wechat userinfo failed: \(error.debugDescription).")
                                            })
                                        }
                }) { error in
                    debugPrint("Request wechat login access_token failed: \(error.debugDescription)")
                }
            }
        }
    }
}
