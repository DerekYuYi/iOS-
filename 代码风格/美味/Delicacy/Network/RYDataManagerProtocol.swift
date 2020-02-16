//
//  RYDataManagerProtocol.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/8.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

enum eRYDataListLoadingType {
    case none // no any loading, error tips, ...
    case zeroData // success but no data
    case loading // initial loading, animation loading for this project
    case notReachable // network wrong
    case error // errors occured: 404, 500
}

@objc protocol RYDataManagerProtocol {
    func ryPerformDownloadData()
    func ryResponseDataRetrival(_ response: Any) -> Any // has a default implementation in extension for optional
}

//extension RYDataManagerProtocol {
//    func ryResponseDataRetrival(_ response: Any) -> Any {
//        return response
//    }
//}


protocol RYDataManagerDelegate: NSObjectProtocol {
    func ryDataManager(_ dataManager: RYBaseDataManager, success: Any?, itemRetrived: Any?)
    
    // Optional
    
    func ryDataManagerAPI(_ dataManager: RYBaseDataManager) -> String?
    func ryDataManagerParms(_ dataManager: RYBaseDataManager) -> [String: Any]
    
    // request from local cache
    func ryDataManagerWithLocalResponse(_ dataManager: RYBaseDataManager) -> [String: Any]
    
    func ryDataManager(_ dataManager: RYBaseDataManager, failure: Error?)
    func ryDataManager(_ dataManager: RYBaseDataManager, cancel isListFull: Bool)
    func ryDataManager(_ dataManager: RYBaseDataManager, status: eRYDataListLoadingType)
}

extension RYDataManagerDelegate {
    
    func ryDataManagerAPI(_ dataManager: RYBaseDataManager) -> String? {
        return ""
    }
    
    func ryDataManagerParms(_ dataManager: RYBaseDataManager) -> [String: Any] {
        return [:]
    }
    
    // request from local cache
    func ryDataManagerWithLocalResponse(_ dataManager: RYBaseDataManager) -> [String: Any] {
        return [:]
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, failure: Error?) {}
    func ryDataManager(_ dataManager: RYBaseDataManager, cancel isListFull: Bool) {}
    func ryDataManager(_ dataManager: RYBaseDataManager, status: eRYDataListLoadingType) {}
}

