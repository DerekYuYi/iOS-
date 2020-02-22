//
//  RYNewsRequester.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/2.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import CommonCrypto

enum eRYDataManagerStatus {
    case loading, empty, error, none // `none` indicates successful state
    
    func isRequesting() -> Bool {
        return self == .loading
    }
}

protocol RYNewsRequesterDelegate: NSObjectProtocol {
    func dataManagerFailed(_ failure: Error?)
    func dataManagerSuccessful(_ success: Any?)
    func dataManager(_ status: eRYDataManagerStatus)
    
    // insert ads datas related
    func topTextBottomImageAdsData() -> [RYNewsItem]
    func tripleImageAdsData() -> [RYNewsItem]
    func bytedanceTripleImageAdsData() -> [RYNewsItem]
}

extension RYNewsRequesterDelegate {
    func dataManagerFailed(_ failure: Error?) {}
    func dataManagerSuccessful(_ success: Any?) {}
    func dataManager(_ status: eRYDataManagerStatus) {}
    
    func topTextBottomImageAdsData() -> [RYNewsItem] { return [] }
    func tripleImageAdsData() -> [RYNewsItem] { return [] }
    func bytedanceTripleImageAdsData() -> [RYNewsItem] { return [] }
}

/// Manages requested data about news.
class RYNewsRequester {
    
    var newsList: [RYNewsItem] = []
    weak var delegate: RYNewsRequesterDelegate?
    var channel: String = "推荐"
    private var refreshTimestamp: Int?
    private var pagingTimestamp: Int?
    private var historyCount: Int = 0 // total page count under the current channel
    var action = "refresh" // refresh or page_down
    var status: eRYDataManagerStatus?
    
    
    init() {
        cleanData()
    }
    
    func cleanData() {
        channel = ""
        delegate = nil
    }
    
    func requestNews() {
        
        // return if the data task is requesting.
        if let statusValue = status, statusValue.isRequesting() { return }
        
        let baseAPI = "http://o.go2yd.com/open-api/op400/recommend_channel?"
        let getAPI = baseAPI + prepareGetParameters()
        guard let api = getAPI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: api) else {
            assert(false, "\(#function) error occured: The url is nil.")
            return
        }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postDict =  ["clientInfo": preparePostParameters()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
        
        // visible network indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        status = .loading
        delegate?.dataManager(.loading)
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) {[weak self] (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                strongSelf.status = .error
                strongSelf.delegate?.dataManager(.error)
                strongSelf.delegate?.dataManagerFailed(error)
            } else {
                guard let data = data else { return }
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let dict = dict as? [String: Any], let status = dict["code"] as? Int, status == 0 {
                        if let resultArr = dict["result"] as? [[String: Any]] {
                            var helperArray: [RYNewsItem] = []
                            
                            // store previous count (in order to calculate the output)
                            let previousCount = strongSelf.newsList.count
                            
                            // 1.retrieve news item from origin data
                            if resultArr.count == 0 {
                                if previousCount == 0 {
                                    debugPrint("Empty list")
                                } else {
                                    debugPrint("No more data")
                                }
                                strongSelf.status = .empty
                                strongSelf.delegate?.dataManager(.empty)
                            } else {
                                strongSelf.status = eRYDataManagerStatus.none
                                strongSelf.delegate?.dataManager(.none)
                                for item in resultArr {
                                    let newsItem = RYNewsItem(item)
                                    helperArray.append(newsItem)
                                }
                                
                                // 2. insert ads
                                if let delegate = strongSelf.delegate {
                                    if strongSelf.channel == "旅游" && delegate.topTextBottomImageAdsData().count > 0 {
                                        let adItem = delegate.topTextBottomImageAdsData()[Int.random(in: 0..<delegate.topTextBottomImageAdsData().count)]
                                        
                                        if helperArray.count >= 10 {
                                            helperArray.insert(adItem, at: 8)
                                        }
                                        
                                        if helperArray.count >= 20 {
                                            helperArray.insert(adItem, at: 18)
                                        }
                                        
                                    } else if strongSelf.channel == "体育" && delegate.tripleImageAdsData().count > 0 {
//                                        let adItem = RYNewsItem(["dtype":"mdadTripleImages"])
                                        let adItem = delegate.tripleImageAdsData()[Int.random(in: 0..<delegate.tripleImageAdsData().count)]
                                        
                                        if helperArray.count >= 10 {
                                            helperArray.insert(adItem, at: 8)
                                        }
                                        
                                        if helperArray.count >= 20 {
                                            helperArray.insert(adItem, at: 18)
                                        }
                                    }
                                }
                                
                                // 3. construct news list
                                if strongSelf.action == "refresh" { // refresh
                                    strongSelf.newsList.removeAll()
                                    strongSelf.newsList = helperArray
                                } else { // paging
                                    strongSelf.newsList.append(contentsOf: helperArray)
                                }
                            }
                            
                            // record for paging
                            var addedCounts: [Int] = []
                            if strongSelf.newsList.count > previousCount {
                                for index in previousCount..<strongSelf.newsList.count {
                                    addedCounts.append(index)
                                }
                            }
                            
                            strongSelf.delegate?.dataManagerSuccessful(addedCounts)
                            
                            // save the first news and the last news timestamp
                            strongSelf.retrieveHistoryTimestamp()
                        }
                    } else {
                        strongSelf.delegate?.dataManager(.error)
                        strongSelf.delegate?.dataManagerFailed(error)
                    }
                } catch {
                    strongSelf.delegate?.dataManager(.error)
                    strongSelf.delegate?.dataManagerFailed(error)
                }
            }
        }.resume()
    }
    
    private func retrieveHistoryTimestamp() {
        if newsList.count > 0 {
            if let updatedTimeString = newsList[0].date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let date = dateFormatter.date(from: updatedTimeString) {
                    refreshTimestamp = Int(date.timeIntervalSince1970)
                }
                
//                let component = RYFormatter.timeMargins(fromTime: updatedTimeString, dateFormat: "yyyy-MM-dd HH:mm:ss")
//                refreshTimestamp = component?.second
            }
            
            if let lastNews = newsList.last,
                let updatedTimeString = lastNews.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let date = dateFormatter.date(from: updatedTimeString) {
                    pagingTimestamp = Int(date.timeIntervalSince1970)
                }
//                let component = RYFormatter.timeMargins(fromTime: updatedTimeString, dateFormat: "yyyy-MM-dd HH:mm:ss")
//                pagingTimestamp = component?.second
            }
        }
    }
    
    private func prepareGetParameters() -> String {
        // 1. authorition related
        let appNewsID = "yLlQSNJK8LExMZ6VnaUpFAtd"
        let appNewsKey = "KSmXMXtIN7cOI7IHDUZ8H8zpLGSx9dXI"
        
        let timeInterval = Date().timeIntervalSince1970
        let timestamp = Int(timeInterval)
        let randomStr = String.randomString(from: 8)
        
        let secretKey = (appNewsKey.MD5() + randomStr + String(timestamp)).SHA1()
        
        let partOne = "appid=\(appNewsID)&timestamp=\(timestamp)&nonce=\(randomStr)&secretkey=\(secretKey)"
        
        // 2. user related
        let partTwo = "&3rd_userid=\(RYDeviceInfoCollector.shared.identifierForAdvertising.MD5())"
        
        // 3. behavior
        let action = self.action // refresh or page_down
        let refresh: Int = 1
        let channel = self.channel
        let count = 20
        let history_count = newsList.count
        var history_timestamp = 0
        if action == "refresh" {
            history_timestamp = refreshTimestamp ?? timestamp // refresh -> 顶部文章的时间戳; paging -> 底部文章的时间戳, 单位为 second
        } else if action == "page_down" {
            history_timestamp = pagingTimestamp ?? timestamp
        }
        /*
        var city = ""
        if channel == "本地" { // need city code
            if let location = RYCacheManager.savedLocation(), !location.name.isEmpty {
                city = location.name
            }
        }
        */
        
        let partThree = "&action=\(action)&refresh=\(refresh)&channel=\(channel)&count=\(count)&history_count=\(history_count)&history_timestamp=\(history_timestamp)"
        
        // 4. others
        let version = "010101"
        let net = RYDeviceInfoCollector.shared.reachabilityStatus()
        let platform = "ios"
        let partFourth = "&version=\(version)&net=\(net)&platform=\(platform)"
        
        return partOne + partTwo + partThree + partFourth
    }
    
    private func preparePostParameters() -> String {
        // 5. clientInfo (post parameters)
        let userInfo: [String : Any] = ["mac": RYDeviceInfoCollector.shared.mac,
                                        "ifa": RYDeviceInfoCollector.shared.identifierForAdvertising.MD5(),
                                        "ip": RYDeviceInfoCollector.shared.ipAddress,
                                        "appVersion": RYDeviceInfoCollector.shared.appVersion,
                                        "3rd_ad_version": "1.0"]
        
        let deviceInfo: [String : Any] = ["screenHeight": UIScreen.main.bounds.height,
                          "screenWidth": UIScreen.main.bounds.width,
                          "device": RYDeviceInfoCollector.shared.deviceModel,
                          "iosVersion": RYDeviceInfoCollector.shared.systemVersion,
                          "network": RYDeviceInfoCollector.shared.reachabilityStatus()]
        if let resultString = jsonString(from: ["userInfo": userInfo, "deviceInfo": deviceInfo]) {
            return resultString
        }
        return ""
    }
    
    // MARK: - JSON formatter
    private func jsonString(from dictionary: [AnyHashable: Any]) -> String? {
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            assertionFailure("\(#function) error occured: dictionary is not a valid json object.")
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    private func dictionary(from jsonString: String) -> [AnyHashable: Any]? {
        guard jsonString.count > 0 else  {
            return nil
        }
        if let data = jsonString.data(using: .utf8) {
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let dict = dict as? [AnyHashable: Any] {
                    return dict
                }
                return nil
            } catch {
                return nil
            }
        }
        return nil
    }
}


// MARK: - news model

enum eRYNewsDisplayType {
    case threePicture, bigPicture, singlePicture, noPicture, mdadTripleImages, mdadTopTextBottomImage, bytedanceTripleImages
}

struct RYNewsItem {
    
    var title: String?
    var detailsTitle: String?
    var ctype: String? // video, news,
    var dtype: eRYNewsDisplayType? // threepic, bigpic, singlepic, nopic
    var imageUrls: [String]? // adapt for dtype
    var videoImage: String?
    var date: String? // 2017-10-26 15:04:19
    var source: String?
    var commentCount: Int?
    var detailsUrl: String?
    var favoriteCount: Int?
    var playCount: Int?
    var duration: Int?
    var order: Int? // for other ads
    
    init(_ data: [AnyHashable: Any]) {
        guard data.count > 0 else { return }
        
        if let title = data["title"] as? String {
            self.title = title
        }
        
        if let title = data["desc"] as? String {
            self.detailsTitle = title
        }
        
        if let ctype = data["ctype"] as? String {
            self.ctype = ctype
        }
        
        if let dtype = data["dtype"] as? String {
            switch dtype {
            case "threepic":
                self.dtype = .threePicture
            case "bigpic":
                self.dtype = .bigPicture
            case "singlepic":
                self.dtype = .singlePicture
            case "nopic":
                self.dtype = .noPicture
            case "mdadTripleImages":
                self.dtype = .mdadTripleImages
            case "mdadTopTextBottomImage":
                self.dtype = .mdadTopTextBottomImage
            case "bytedanceTripleImages":
                self.dtype = .bytedanceTripleImages
            default:
                break
            }
        }
        
        if let imageUrls = data["image_urls"] as? [String] {
            self.imageUrls = imageUrls
        }
        
        if let videoImage = data["image"] as? String {
            self.videoImage = videoImage
        }
        
        if let date = data["date"] as? String {
            self.date = date
        }
        
        if let source = data["source"] as? String {
            self.source = source
        }
        
        if let commentCount = data["comment_count"] as? Int {
            self.commentCount = commentCount
        }
        
        if let detailsUrl = data["url"] as? String {
            self.detailsUrl = detailsUrl
        }
        
        if let favoriteCount = data["up"] as? Int {
            self.favoriteCount = favoriteCount
        }
        
        if let playCount = data["play_count"] as? Int {
            self.playCount = playCount
        }
        
        if let duration = data["duration"] as? Int {
            self.duration = duration
        }
        
        if let order = data["order"] as? Int {
            self.order = order
        }
        
    }
}
