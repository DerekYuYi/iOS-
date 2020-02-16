//
//  RYDishDetailsModel.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/23.
//  Copyright © 2018 RuiYu. All rights reserved.
//

/// Codable replace

struct RYDishDetailsModel {
    var title: String?
    var albums: String?
    var introduction: String?
    var isCollection: Bool?
    
    var ingredients: [RYInGredient]?
    var steps: [RYStep]?
    
    
    init(_ data: [String: Any]) {
        if let titleString = data["title"] as? String {
            title = titleString
        }
        
        if let albumsString = data["albums"] as? String {
            albums = albumsString
        }
        
        if let introductionString = data["introduction"] as? String {
            introduction = introductionString
        }
        
        if let isCollection = data["is_collection"] as? Bool {
            self.isCollection = isCollection
        }
        
        if let ingredients = data["ingredients"] as? [[String: Any]] {
            var helperArray: [RYInGredient] = []
            
            for item in ingredients {
                let ingredient = RYInGredient(item)
                helperArray.append(ingredient)
            }
            self.ingredients = helperArray
        }
        
        if let steps = data["steps"] as? [[String: Any]] {
            var helperArray: [RYStep] = []
            
            for item in steps {
                let step = RYStep(item)
                helperArray.append(step)
            }
            self.steps = helperArray
        }
        
    }
}

struct RYInGredient {
    var name: String?
    var size: String?
    
    init(_ data: [String: Any]) {
        if let nameString = data["name"] as? String {
            name = nameString
        }
        
        if let sizeString = data["size"] as? String {
            size = sizeString
        }
    }
}

struct RYStep {
    var order: Int?
    var content: String?
    var imageLinkString: String?
    
    init(_ data: [String: Any]) {
        if let orderValue = data["number"] as? Int {
            order = orderValue
        }
        
        if let contentValue = data["content"] as? String {
            content = contentValue
        }
    
        if let imageLinkStringValue = data["img"] as? String {
            imageLinkString = imageLinkStringValue
        }
    }
}
