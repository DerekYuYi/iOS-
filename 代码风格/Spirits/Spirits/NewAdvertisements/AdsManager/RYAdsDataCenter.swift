//
//  RYAdsDataCenter.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/8.
//  Copyright © 2019 RuiYu. All rights reserved.
//
 /*
    Abstract: Manages ads related logics such as request ads, to gather statistic ads's presents or clicks, and so on...
 */

import UIKit
import Kingfisher

/// Indicates that ads types.
enum eRYAdsType: Int {
    case coopen = 800001, bannerTop = 800002, bannerBottom = 800003
    
    func covertString() -> String {
        return String(self.rawValue)
    }
}

/// Indicates that ads has presented or has clicked.
enum eRYAdsStatisticsType: Int {
    case present = 0, click
}

class RYAdsDataCenter: NSObject {
    
    // MARK: - Properties
    
    static let sharedInstance = RYAdsDataCenter()
    
    /// Indicates that all ads has retrieved to models.
    var adsDict: [String: [RYAdvertisement]] = [:]
    
    /// Returns a Boolean value indicating whether the adsDict contains the
    /// given type ads.
    /// - Parameter type: The type of ads.
    func isExistAds(for type: eRYAdsType) -> Bool {
        guard adsDict.count > 0 && adsDict.keys.contains(String(type.rawValue)) else { return false }
        
        if let ad = adsDict[String(type.rawValue)], ad.count > 0 { return true }
        return false
    }
    
    // MARK: - Request Ads API
    
    /// Requests all ads of current apps.
    func requestAdsAPI() {
        // preparation
        guard let adsUrlString = prepareParams(), let url = URL(string: adsUrlString) else {
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let sessionDataTask = session.dataTask(with: request) {[weak self] (data: Data?, response: URLResponse?, error: Error?) in
            guard let _ = response, let data = data, let strongSelf = self, error == nil else {
                debugPrint("****requestAdsAPI failed.****")
                return
            }
            
            /// Int 1 indicated success, otherwise failed
            let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dict = dict as? [String: Any] {
                if let code = dict["code"] as? Int, code == 1 {
                    
                    // retrieve response
                    strongSelf.retrieveAdsResponse(dict)
                    
                    // check if existed .coopen type, clear the caches if not return .coopen type to keep asynchronous with api data.
                    if !RYAdsDataCenter.sharedInstance.isExistAds(for: .coopen) {
                        RYUserDefaultCenter.clearCoopenImageData()
                    }
                    
                } else {
                    debugPrint("Code Returned is not 1")
                }
            }
        }
        sessionDataTask.resume()
    }
    
    /// Retrieve response back from request ads api.
    /// - Parameter data: Array or Dictionary
    private func retrieveAdsResponse(_ data: Any?) {
        if let dict = data as? [String: Any],
            let contents = dict["data"] as? [[String: Any]], contents.count > 0 {
            
            for adDict in contents {
                
                for (key, value) in adDict {
                    
                    // 1. retrieve `value` to model
                    var helperArray: [RYAdvertisement] = []
                    if let ads = value as? [[String: Any]], ads.count > 0 {
                        for item in ads {
                            /*
                            let itemData = try? JSONSerialization.data(withJSONObject: item, options: JSONSerialization.WritingOptions.prettyPrinted)
                            if let itemData = itemData {
                                let adItem = try? JSONDecoder().decode(RYAdvertisement.self, from: itemData)
                             if let adItem = adItem { helperArray.append(adItem) }
                             
                             }
                            */
                            let adItem = RYAdvertisement(item)
                            helperArray.append(adItem)
                        }
                    }
                    
                    // 2. retrieve `key` and match types of ads
                    var adType: eRYAdsType?
                    switch key {
                    case eRYAdsType.coopen.covertString():
                        adType = .coopen
                        
                        // prefetch image
                        prefetchImage(helperArray.first)
                        
                    case eRYAdsType.bannerTop.covertString():
                        adType = .bannerTop
                        
                    case eRYAdsType.bannerBottom.covertString():
                        adType = .bannerBottom
                        
                    default:
                        break
                    }
                    
                    // 3. update adsDict
                    if let _ = adType {
                        adsDict.updateValue(helperArray, forKey: key)
                    }
                }
            }
        }
    }
    
    /// Prefetch images
    private func prefetchImage(_ ad: RYAdvertisement?) {
        if let advertiment = ad,
            let imageUrlString = advertiment.resource?.first,
            let url = URL(string: imageUrlString), !imageUrlString.isEmpty {
            
            // cache to userdefault
            RYUserDefaultCenter.cacheCoopenImageData(for: advertiment)
            
            // download and cache image
            let imagePrefetcher = ImagePrefetcher(urls: [url])
            imagePrefetcher.start()
            
        }
    }
    
    
    /// Requests all ads of current apps.
    ///
    /// - Parameters:
    ///   - adid: An int value, indicates that the unique identifier of the ad.
    ///   - countType: A type of enum `eRYAdsStatisticsType`, indicates that ads has presented or has clicked.
    func countAds(for adid: Int, withType countType: eRYAdsStatisticsType) {
        // Check API
        guard let adsUrlString = prepareParams(), let url = URL(string: adsUrlString) else {
            return
        }
        
        // Prepare URLRequest
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var params = RYDeviceInfoCollector.shared.sspInfos()
        params.updateValue(NSNumber(value: adid), forKey: "id")
        params.updateValue(NSNumber(value: countType.rawValue), forKey: "type")
        
        if JSONSerialization.isValidJSONObject(params) {
            let bodyData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            if let data = bodyData {
                request.httpBody = data
            }
        }
        
        // Prepare URLSession
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let sessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard let _ = response, let data = data, error == nil else {
                debugPrint("****Counting Failed for actions of ads \(adid): \(countType).****")
                return
            }
            let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dict = dict as? [String: Any] {
                if let code = dict["code"] as? Int, code == 1 {
                    debugPrint("****Counting Successfully for actions of ads \(adid): \(countType).****")
                }
            }
        }
        sessionDataTask.resume()
    }
    
    // MARK: - Parameters preparation for requests
    
    private func prepareParams() -> String? {
        let appKey = "65555523"
        let appSecret = "3beefb064945228453be4e54cb49e3878c4f71ac"
        
        let timeInterval = Date().timeIntervalSince1970
        
        // save value of `time interval` to keep timestamp synchronous
        let timestamp = timeInterval
        
        let sign = ("key=\(appKey)" + "&" + "secret_key=\(appSecret)" + "&" + "timestamp=\(timestamp)").SHA1()
        
        let httpProtocol = "http"
        let domain = "sspapi.datasever.com"
        let adsApiString: String? = "\(httpProtocol)://\(domain)/api/\(appKey)/ads/?sign=\(sign)&timestamp=\(timestamp)"
        
        return adsApiString
    }
    
}

// MARK: - Single Ad data structure

class RYAdvertisement: NSObject, Codable, NSCoding {
    
    private struct CodingKey {
        static let adid = "RYAdvertisement_id"
        static let description = "RYAdvertisement_description"
        static let name = "RYAdvertisement_name"
        static let resource = "RYAdvertisement_resource"
        static let click_url = "RYAdvertisement_click_url"
        static let origin = "RYAdvertisement_origin"
    }
    
    var id: Int = -1 // -1 indicates invalid id of ads'.
    var descriptionText: String?
    var name: String?
    var click_url: String?
    var origin: String?
    var resource: [String]? // image_urls, may be greater than one, default access the first object of array.
    
    
    init(_ data: [String: Any]) {
        super.init()
        
        if let adid = data["id"] as? Int {
            id = adid
        }
        
        if let desc = data["description"] as? String {
            descriptionText = desc
        }
        
        if let nameStr = data["name"] as? String {
            name = nameStr
        }
        
        if let clickUrl = data["click_url"] as? String {
            click_url = clickUrl
        }
        
        if let originStr = data["origin"] as? String {
            origin = originStr
        }
        
        if let image_urls = data["resource"] as? [String] {
            resource = image_urls
        }
    }
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: CodingKey.adid)
        aCoder.encode(descriptionText, forKey: CodingKey.description)
        aCoder.encode(name, forKey: CodingKey.name)
        aCoder.encode(click_url, forKey: CodingKey.click_url)
        aCoder.encode(origin, forKey: CodingKey.origin)
        aCoder.encode(resource, forKey: CodingKey.resource)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        id = aDecoder.decodeInteger(forKey: CodingKey.adid)
        
        if let desc = aDecoder.decodeObject(forKey: CodingKey.description) as? String {
            descriptionText = desc
        }
        
        if let nameStr = aDecoder.decodeObject(forKey: CodingKey.name) as? String {
            name = nameStr
        }
        
        if let clickUrl = aDecoder.decodeObject(forKey: CodingKey.click_url) as? String {
            click_url = clickUrl
        }
        
        if let originStr = aDecoder.decodeObject(forKey: CodingKey.origin) as? String {
            origin = originStr
        }
        
        if let resources = aDecoder.decodeObject(forKey: CodingKey.resource) as? [String] {
            resource = resources
        }
    }
    
}
