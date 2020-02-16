//
//  RYCategoryDataManager.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/26.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class RYCategoryDataManager: RYBaseDataManager {
    
    var categories: [RYCategoryModel] = []
    
    override init(_ delegate: RYDataManagerDelegate?) {
        categories = []
        super.init(delegate)
    }
    
    override func ryResponseDataRetrival(_ response: Any) -> Any {
        guard let responseData = response as? DataResponse<Data>, let data = responseData.data else {
            return response
        }
        
        let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
            if let data = dict["data"] as? [[String: Any]], data.count > 0 {
                for item in data {
                let categoryItem = RYCategoryModel(item)
                    categories.append(categoryItem)
                }
            }
        }
        return categories
    }
    
    // MARK: - Pubilc methods
    override func cleanData() {
        categories = []
    }
    
    override func hasValidData() -> Bool {
        return categories.count > 0
    }
}
