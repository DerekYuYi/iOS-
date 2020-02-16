//
//  RYSquareDataManager.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/2/25.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Alamofire

class RYSquareDataManager: RYBaseDataManager {
    
    var shareList: [RYExperience] = []
    
    override init(_ delegate: RYDataManagerDelegate?) {
        shareList = []
        super.init(delegate)
    }
    
    /// override protocol method for retrival response when request successfully.
    /// - parameter response: The response when request successfully.
    override func ryResponseDataRetrival(_ response: Any) -> Any {
        guard let responseData = response as? DataResponse<Data>, let data = responseData.data else {
            return response
        }
        
        let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        
        if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
            if let experienceList = dict["data"] as? [[String: Any]], data.count > 0 {
                var helper: [RYExperience] = []
                for item in experienceList {
                    helper.append(RYExperience(item))
                }
                shareList.append(contentsOf: helper)
            }
        }
        return [] // NOTE: Do not use the result
    }
    
    override func cleanData() {
        shareList = []
    }
}
