//
//  RYFavoritesDataManager.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/4/4.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import Alamofire

class RYFavoritesDataManager: RYBaseDataManager {
    var dishList: [RYDishModel] = []
    
    override init(_ delegate: RYDataManagerDelegate?) {
        dishList = []
        super.init(delegate)
    }
    
    override func ryResponseDataRetrival(_ response: Any) -> Any {
        guard let responseData = response as? DataResponse<Data>, let data = responseData.data else {
            return response
        }
        
        let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        
        if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
            
            // retrieve list
            if let items = dict["data"] as? [[String: Any]], items.count > 0 {
                var dishes: [RYDishModel] = []
                
                for item in items {
                    let decoder = JSONDecoder()
                    let itemData = try? JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
                    if let itemData = itemData {
                        let dish = try? decoder.decode(RYDishModel.self, from: itemData)
                        if let dish = dish {
                            dishes.append(dish)
                        }
                    }
                }
                
                // assignment for dishlist
                dishList.append(contentsOf: dishes)
            }
        }
        return dishList
    }
    
    // MARK: - Pubilc methods
    override func cleanData() {
        dishList = []
    }
    
    override func hasValidData() -> Bool {
        return dishList.count > 0
    }
    
}
