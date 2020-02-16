//
//  RYDishDetailsDataManager.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/23.
//  Copyright © 2018 RuiYu. All rights reserved.
//


import Foundation
import UIKit
import Alamofire

class RYDishDetailsDataManager: RYBaseDataManager {
    
    var dishDetails: RYDishDetailsModel?
    
    override init(_ delegate: RYDataManagerDelegate?) {
        dishDetails = nil
        super.init(delegate)
    }
    
    override func ryResponseDataRetrival(_ response: Any) -> Any {
        guard let responseData = response as? DataResponse<Data>, let data = responseData.data else {
            return response
        }
        
        let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        
        if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
            
            if let data = dict["data"] as? [String: Any], data.count > 0 {
                dishDetails = RYDishDetailsModel(data)
            }
        }
        return dishDetails ?? response
    }
    
    // MARK: - Pubilc methods
    override func cleanData() {
        dishDetails = nil
    }
    
    override func hasValidData() -> Bool {
        guard let _ = dishDetails else { return false }
        return true
    }
}

