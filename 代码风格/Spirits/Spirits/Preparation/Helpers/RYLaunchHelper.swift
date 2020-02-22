//
//  RYDeviceInfoCollector.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/19.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import Alamofire

enum eRYRequestType {
    case local, tripartite
}

class RYLaunchHelper: NSObject {
    
    // set timeInterval global for all requests
    static let shared: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15.0
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    static func request(_ api: String?,
                        method: HTTPMethod = .get,
                        type: eRYRequestType? = nil,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding? = nil,
                        headers: [String: String]? = nil,
                        successHandler: (([AnyHashable: Any]) -> Void)? = nil,
                        failureHandler: ((Any?) -> Void)? = nil) {
        
        guard let checkApi = api, !checkApi.isEmpty else { return }
        guard let encodingApi = checkApi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !encodingApi.isEmpty else { return }
        
        guard let url = URL(string: encodingApi) else { return }
        
        let dataRequest: DataRequest
        
        if let unwrappedEncoding = encoding {
            dataRequest = Alamofire.request(url,
                                                method: method,
                                                parameters: parameters,
                                                encoding: unwrappedEncoding,
                                                headers: headers)
        } else {
            dataRequest = Alamofire.request(url,
                                                method: method,
                                                parameters: parameters,
                                                encoding: URLEncoding.default,
                                                headers: headers)
        }
        
        dataRequest.responseData { response in
            switch response.result {
            case .success:
                guard let successHandler = successHandler else { return }
                
                guard let data = response.data else {
                    if let failureHandler = failureHandler {
                        failureHandler(nil)
                    }
                    return
                }
                
                let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                
                /// handle tripartite api callback
                if let type = type, type == .tripartite {
                    if let dict = dict as? [String: Any] {
                        successHandler(dict)
                    } else {
                        successHandler([:])
                    }
                    return
                }
                debugPrint(dict ?? "dict is nil")
                /*
                 if let dict = dict as? [String: Any] {
                 debugPrint(dict)
                 }
                 */
                
                // "1" indicates success
                if let dict = dict as? [String: Any], let code = dict["code"] as? Int {
                    if code == 1 {
                        successHandler(dict)
                        return
                    } else {
                        if let failureHandler = failureHandler {
                            failureHandler(nil)
                            return
                        }
                    }
                } else {
                    if let failureHandler = failureHandler {
                        if let res = response.response, res.statusCode >= 500 && res.statusCode < 600 {
                            failureHandler(res.statusCode)
                        } else {
                            failureHandler(nil)
                        }
                        return
                    }
                }
                
            case .failure(let error):
                debugPrint("\(#function) is received failed.")
                if let failureHandler = failureHandler {
                    if let res = response.response, res.statusCode >= 500 && res.statusCode < 600 {
                        failureHandler(res.statusCode)
                    } else {
                        failureHandler(error)
                    }
                    return
                }
            }
        }
    }
    
    static func validList() -> [String] {
        guard let infoDict = Bundle.main.infoDictionary, infoDict.count > 0 else { return [] }
        guard let applicationSchemes = infoDict["LSApplicationQueriesSchemes"] as? [String], applicationSchemes.count > 0 else { return [] }
        
        var helperArray: [String] = []
        
        helperArray.removeAll()
        for item in applicationSchemes {
            let urlString = item.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + "://"
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                helperArray.append(urlString)
            }
        }
        
        return helperArray
    }
    
}
