//
//  RYBaseDataManager.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/8.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Alamofire

class RYBaseDataManager: NSObject {
    
    // MARK: - Properties
    var storedURLString: String? // request api
    weak var dataDelegate: RYDataManagerDelegate?
    var isRequesting = false
    
    private var sessionManager: SessionManager?
    
    // MARK: - Init
    init(_ delegate: RYDataManagerDelegate?){
        dataDelegate = delegate
        
        sessionManager = nil
        storedURLString = nil
        isRequesting = false
    }
    
    // MARK: - Public
    func hasValidData() -> Bool {
        return false // default value
    }
    
    func cleanData() {
        
    }
    
    func isDownLoading() -> Bool {
        return false // default value
    }
    
    
}

extension RYBaseDataManager: RYDataManagerProtocol {
    func ryPerformDownloadData() {
        // 1. local data handlings
        if routineLocalDataHandlings() { return }
        
        // 2. check network
//        NetworkReachabilityManager (yes, you can)
        
        // 3. API parameters
        let api = routinesAssembleAPI()
        guard let url = URL(string: api) else { return }
        
        isRequesting = true
        
        // 3.1.
        // add cookie(login-sessionid)
        RYDataManager.constructLoginCookie(for: url)
        
        // 4. data status indicator
        dataDelegate?.ryDataManager(self, status: .loading)
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        // 5. http
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        let dataRequest = Alamofire.request(request)
        
        dataRequest.responseData {[weak self] response in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            // 5.1 guard
            guard let strongSelf = self else {
                return
            }

            switch response.result {
            case .success:
                strongSelf.successfulHandler(for: response)
                
            case.failure(let error):
                strongSelf.failureHandler(for: response, error: error)
            }
        }
    }
    
    private func routineLocalDataHandlings() -> Bool {
        // request from local response
        return false
    }
    
    private func routinesAssembleAPI() -> String {
        var targetAPI = ""
        if let api = dataDelegate?.ryDataManagerAPI(self), !api.isEmpty {
            targetAPI = api
        } else if let storedURLString = self.storedURLString, !storedURLString.isEmpty {
            targetAPI = storedURLString
            debugPrint(targetAPI, separator: "**********", terminator: "^^^^APIAPI^^^^")
        }
        return targetAPI
    }
    
    private func successfulHandler(for response: DataResponse<Data>) {
        // success but 404 (may be)
        if let res = response.response, res.statusCode == 404 { // may be?
            dataDelegate?.ryDataManager(self, status: .error)
            isRequesting = false
            return
        }
        
        // success download delegate
        let dataAdded = self.ryResponseDataRetrival(response)
        dataDelegate?.ryDataManager(self, success: response, itemRetrived: dataAdded)
        
        // data status indicator
        dataDelegate?.ryDataManager(self, status: .none)
    }
    
    private func failureHandler(for response: DataResponse<Data>, error: Error) {
        // 1. failure delegate
        dataDelegate?.ryDataManager(self, failure: error)
        
        // 2. data status indicator
        dataDelegate?.ryDataManager(self, status: .error)
    }
    
    func ryResponseDataRetrival(_ response: Any) -> Any {
        return response
    }
    
}
