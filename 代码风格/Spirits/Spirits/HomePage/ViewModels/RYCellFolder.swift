//
//  RYCellFolder.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/10.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation


struct RYCellFolder {
    
    var records = Set<IndexPath>()
    
    func isContainedIndexPath(at indexPath: IndexPath) -> Bool {
        if records.contains(indexPath) {
            return true
        }
        return false
    }
    
    mutating func recordIndexPath(at indexPath: IndexPath) {
        records.insert(indexPath)
    }
    
    mutating func removeIndexPath(at indexPath: IndexPath) {
        records.remove(indexPath)
    }
        
}
