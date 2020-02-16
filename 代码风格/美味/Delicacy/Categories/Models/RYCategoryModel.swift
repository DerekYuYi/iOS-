//
//  RYCategoryModel.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/26.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

struct RYCategoryModel  {
    var id: Int?
    var name: String?
    var imageUrl: String?
    var subCategories: [RYCategoryModel]?
    
    init(_ data: [String: Any]) {
        if let id = data["id"] as? Int {
            self.id = id
        }
        
        if let name = data["name"] as? String {
            self.name = name
        }
        
        if let imageUrl = data["image_url"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let childrens = data["children"] as? [[String: Any]] { // will not cause retain cycle.
            var helperArray: [RYCategoryModel] = []
            for item in childrens {
                let model = RYCategoryModel(item)
                helperArray.append(model)
            }
            subCategories = helperArray
        }
    }
}
