//
//  RYAPIRequester.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/15.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import Alamofire

class RYAPIRequester: NSObject {
    
    static func request(_ api: String?,
                        method: HTTPMethod = .get,
                        type: eRYRequestType? = nil,
                        parameters: Parameters? = nil,
                        encoding: URLEncoding? = nil,
                        needUserAuthorizationHeaders: Bool? = nil,
                        successHandler: (([AnyHashable: Any]) -> Void)? = nil,
                        failureHandler: ((Any?) -> Void)? = nil) {
        
        // check api
        guard let checkApi = api, !checkApi.isEmpty else { return }
        guard let encodingApi = checkApi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !encodingApi.isEmpty else { return }
        
        guard let url = URL(string: encodingApi) else { return }
        
        // prepare urlencoding
        var defaultEncoding = URLEncoding.default
        if let unwrappedEncoding = encoding {
            defaultEncoding = unwrappedEncoding
        }
        
        // prepare customize header: There is only add token when user has logined
        var headers: HTTPHeaders? = nil
        if let _ = needUserAuthorizationHeaders, let token = RYProfileCenter.me.token {
            let tokenValue = "JWT " + token
            headers = ["Authorization": tokenValue]
        }
        
        // prepare data request
        let dataRequest = Alamofire.request(url,
                                            method: method,
                                            parameters: parameters,
                                            encoding: defaultEncoding,
                                            headers: headers)
        
        // starts visible network indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        // request
        dataRequest.responseData { response in
            
            // ends visible network indicator
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
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
}
