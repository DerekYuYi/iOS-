//
//  RYHPDataManager.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/19.
//  Copyright © 2018 RuiYu. All rights reserved.
//

//import Foundation
//import UIKit
import Alamofire

class RYHPDataManager: RYBaseDataManager {
    
    var banners: [RYBanner]?
    var skills: [RYSKill]?
    var experiences: [RYExperience]?
    var hotRecipes: [RYDishModel]?
    var lastestRecipes: [RYDishModel]?
    
    
    override init(_ delegate: RYDataManagerDelegate?) {
        banners = nil
        skills = nil
        experiences = nil
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
            if let data = dict["data"] as? [String: Any], data.count > 0 {
                if let bannerList = data["carousel"] as? [[String: Any]], bannerList.count > 0 {
                    var helper: [RYBanner] = []
                    for item in bannerList {
                        helper.append(RYBanner(item))
                    }
                    banners = helper
                }
                
                if let skillList = data["skill_list"] as? [[String: Any]], skillList.count > 0 {
                    var helper: [RYSKill] = []
                    for item in skillList {
                        helper.append(RYSKill(item))
                    }
                    skills = helper
                }
                
                if let experienceList = data["cooking_sharing"] as? [[String: Any]], experienceList.count > 0 {
                    var helper: [RYExperience] = []
                    for item in experienceList {
                        helper.append(RYExperience(item))
                    }
                    experiences = helper
                }
                
                if let hotList = data["hot_recipe"] as? [[String: Any]], hotList.count > 0 {
                    hotRecipes = decodeDishModel(from: hotList)
                }
                
                if let lastestList = data["new_recipe"] as? [[String: Any]], lastestList.count > 0 {
                    lastestRecipes = decodeDishModel(from: lastestList)
                }
                
                
            }
        }
        return [] // NOTE: Do not use the result
    }
    
    private func decodeDishModel(from sourceList: [[String: Any]]) -> [RYDishModel] {
        var helper: [RYDishModel] = []
        
        for item in sourceList {
            let decoder = JSONDecoder()
            let itemData = try? JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
            if let itemData = itemData {
                let dish = try? decoder.decode(RYDishModel.self, from: itemData)
                if let dish = dish {
                    helper.append(dish)
                }
            }
        }
        return helper
    }
    
    // MARK: - Public methods
    override func cleanData() {
        banners = nil
        skills = nil
        experiences = nil
        hotRecipes = nil
        lastestRecipes = nil
    }
    
    override func hasValidData() -> Bool {
        var hasBanner = false
        var hasSkill = false
        var hasExperience = false
        var hasHotRecipes = false
        var hasLastestRecipes = false
        
        if let _ = banners {
            hasBanner = true
        }
        
        if let _ = skills {
            hasSkill = true
        }
        
        if let _ = experiences {
            hasExperience = true
        }
        
        if let _ = hotRecipes {
            hasHotRecipes = true
        }
        
        if let _ = lastestRecipes {
            hasLastestRecipes = true
        }
        
        return hasBanner || hasSkill || hasExperience || hasHotRecipes || hasLastestRecipes
    }
}
