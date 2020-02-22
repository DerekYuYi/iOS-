//
//  RYThirdPartiesShareManager.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/22.
//  Copyright © 2019 RuiYu. All rights reserved.
//

/*
 Abstract: Encapsulates the sharing and login of third parties.
 */

import Foundation

/// The enum indicates that all three party sharing platforms suppoprted by this app.
enum eRYSharePlatform: Int {
    case wechatSession = 0, wechatTimeline, qqSession, qqZone, weibo
}

enum eRYShareObjectType {
    case webpage, image
}

class RYThirdPartiesShareManager: NSObject {
    
    private struct Constants {
        static let imageDataKey = "imageData"
        static let webPageUrlKey = "share_webPageUrl"
        static let titleKey = "share_title"
        static let descriptionKey = "share_description"
        static let thumbImageDataKey = "thumbImageData"
        static let thumbImageUrlStringKey = "share_thumbImageUrl"
    }
    
    /// Shares to third parties such as Wechat, QQ, Weibo.
    /// - Parameters:
    ///   - scene: WXScene type.
    ///   - objectType: An enum indicates which object type will to be shared.
    ///   - objectData: A Dictionary type and it contains stable keys. There are keys:
    ///
    ///             ["imageData": Data,
    ///             "share_webPageUrl": String,
    ///             "share_title": String,
    ///             "share_description": String,
    ///             "thumbImageData": Data,
    ///             "share_thumbImageUrl": String]
    ///
    static func share(for platform: eRYSharePlatform,
                      objectType: eRYShareObjectType,
                      objectData: [String: Any]) {
        switch platform {
        case .wechatSession, .wechatTimeline:
            shareToWechat(for: WXScene(UInt32(platform.rawValue)), objectType: objectType, objectData: objectData)
            
        case .qqSession, .qqZone:
            shareToQQ(for: platform.rawValue, objectType: objectType, objectData: objectData)
            
        case .weibo:
            shareToWeibo(for: platform.rawValue, objectType: objectType, objectData: objectData)
        }
    }
    
    /// Share to wechat.
    /// - Parameters:
    ///   - scene: WXScene type.
    ///   - objectType: An enum indicates which object type will to be shared.
    ///   - objectData: A Dictionary type and it contains stable keys. see details in `Constants` struct.
    private static func shareToWechat(for scene: WXScene,
                              objectType: eRYShareObjectType,
                              objectData: [String: Any]) {
        
        guard isWechatInstalled() else {
            return
        }
        
        // Object setup
        var object: AnyObject? = nil
    
        switch objectType {
        case .image:
            let imageObject = WXImageObject()
            if let objectData = objectData[Constants.imageDataKey] as? Data {
                imageObject.imageData = objectData
            }
            object = imageObject
            
        case .webpage:
            let webpageObject = WXWebpageObject()
            if let string = objectData[Constants.webPageUrlKey] as? String, !string.isEmpty {
                webpageObject.webpageUrl = string
            }
            object = webpageObject
        }
        
        let message = WXMediaMessage()
        
        // add thumb image
        if let thumbData = retrieveThumbnailData(from: objectData) {
            message.thumbData = thumbData
        }
        
        // add title
        if let title = objectData[Constants.titleKey] as? String, !title.isEmpty {
            message.title = title
        }
        
        // add description
        if let description = objectData[Constants.descriptionKey] as? String, !description.isEmpty {
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
    
    /// Receives and handles response that wechat authorization for login.
    /// - Parameters:
    ///   - resp: A instance of `SendAuthResp`.
    ///   - appID: A string that generated automatically when create apps under wechat open platform.
    ///   - appSecret: A string that generated automatically when create apps under wechat open platform.
    @objc static func wechatLoginAuthDidResponded(_ resp: SendAuthResp?,
                                                  appID: String,
                                                  appSecret: String) {
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
    
    // MARK: - QQ
    
    /// Shares to QQ.
    /// - Parameters:
    ///   - scene:  type.
    ///   - objectType: An enum indicates which object type will to be shared.
    ///   - objectData: A Dictionary type and it contains stable keys. see details in `Constants` struct.
    private static func shareToQQ(for scene: Int,
                              objectType: eRYShareObjectType,
                              objectData: [String: Any]) {
        
        guard QQApiInterface.isQQInstalled() else { return }
        
        var title = ""
        var detailsContent = ""
        var imageData = Data()
        
        // add title
        if let titleText = objectData[Constants.titleKey] as? String, titleText.count > 0 {
            title = titleText
        }
        
        // add description
        if let description = objectData[Constants.descriptionKey] as? String, !description.isEmpty {
            detailsContent = description
        }
        
        // add link
        guard let string = objectData[Constants.webPageUrlKey] as? String,
            let percentUrlString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let targetUrl = URL(string: percentUrlString) else {
            return
        }
        
        // add thumb image
        if let thumbData = retrieveThumbnailData(from: objectData) {
            imageData = thumbData
        }
        
        // share to QQ
        let newsObj = QQApiNewsObject(url: targetUrl, title: title, description: detailsContent, previewImageData: imageData, targetContentType: QQApiURLTargetTypeNews)
        if let newsObj = newsObj, let req = SendMessageToQQReq(content: newsObj) {
            
            if scene == eRYSharePlatform.qqSession.rawValue { // share to QQ
                let sentQQ = QQApiInterface.send(req)
                debugPrint(sentQQ.rawValue)
                
            } else if scene == eRYSharePlatform.qqZone.rawValue { // share to QZone
                let sentQZone = QQApiInterface.sendReq(toQZone: req)
                debugPrint(sentQZone.rawValue)
            }
        }
    }
    
    static func isQQInstalled() -> Bool {
        return QQApiInterface.isQQInstalled()
    }
    
    // MARK: - Weibo
    
    /// Shares to Weibo.
    /// - Parameters:
    ///   - scene: type.
    ///   - objectType: An enum indicates which object type will to be shared.
    ///   - objectData: A Dictionary type and it contains stable keys. see details in `Constants` struct.
    private static func shareToWeibo(for scene: Int,
                   objectType: eRYShareObjectType,
                   objectData: [String: Any]) {
        
        guard WeiboSDK.isWeiboAppInstalled() else { return }
        
        let message = WBMessageObject()
        
        // share link
        let webpage = WBWebpageObject()
        webpage.objectID = "identifier1"
        
        // add title
        if let titleText = objectData[Constants.titleKey] as? String, titleText.count > 0 {
//            webpage.title = titleText
            message.text = titleText
        }
        
        // add description
        if let descriptionText = objectData[Constants.descriptionKey] as? String, !descriptionText.isEmpty {
            webpage.title = descriptionText
//            webpage.description = descriptionText
        }
        
        // add link
        if let string = objectData[Constants.webPageUrlKey] as? String,
            let percentUrlString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            webpage.webpageUrl = percentUrlString
        }
        
        // add thumb image
        if let thumbData = retrieveThumbnailData(from: objectData) {
            webpage.thumbnailData = thumbData
        }
        
        message.mediaObject = webpage
        
        guard let authRequest = WBAuthorizeRequest.request() as? WBAuthorizeRequest else { return }
        authRequest.redirectURI = "http://www.sina.com"
        authRequest.scope = "all"
        if let request = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo: authRequest, access_token: nil) as? WBSendMessageToWeiboRequest {
            WeiboSDK.send(request)
        }
    }
    
    static func isWeiboInstalled() -> Bool {
        return WeiboSDK.isWeiboAppInstalled()
    }
    
    // MARK: - Helper methods
    
    /// The priority of show thumb image is: thumbImageDataKey -> thumbImageUrlStringKey(network) -> local
    private static func retrieveThumbnailData(from objectData: [String: Any]) -> Data? {
        
        if let thumbData = objectData[Constants.thumbImageDataKey] as? Data {
            return thumbData
            
        } else if let thumbImageUrlString = objectData[Constants.thumbImageUrlStringKey] as? String,
            let thumbImageUrl = URL(string: thumbImageUrlString) {
            
            do {
                let thumbImageData = try Data(contentsOf: thumbImageUrl)
                return thumbImageData
            } catch {
                // use local image
                if let imageIcon = UIImage(named: "icon-20") {
                    return imageIcon.jpegData(compressionQuality: 0.3)
                }
            }
            
        } else {
            if let imageIcon = UIImage(named: "icon-20") {
                return imageIcon.jpegData(compressionQuality: 0.3)
            }
        }
        return nil
    }
    
}

