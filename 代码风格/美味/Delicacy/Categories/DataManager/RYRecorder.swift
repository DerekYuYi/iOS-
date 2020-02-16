//
//  RYRecorder.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/5.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import Foundation

struct RYRecorder {
    
    var records: Set<IndexPath> = []
    
    func hasRecord(at indexPath: IndexPath) -> Bool {
        if records.contains(indexPath) {
            return true
        }
        return false
    }
    
    mutating func record(at indexPath: IndexPath) {
        records.insert(indexPath)
    }
}
