//
//  RYIndexPathRecorder.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

/* Abstract:
   Need refactor with 'RYIndexRecorder.swift'.
 */


import Foundation

struct RYIndexPathRecorder {
    
    static func isContainedIndex(at index: Int) -> Bool {
        if let indexes = RYUserDefaultCenter.hasRecordedIndex(), indexes.count > 0 {
            if indexes.contains(index) {
                return true
            }
        }
        return false
    }
    
    static func recordIndex(at index: Int) {
        if var indexes = RYUserDefaultCenter.hasRecordedIndex(), indexes.count > 0 {
            
            if indexes.contains(index) { return }
            
            indexes.append(index)
            
            RYUserDefaultCenter.recordIndex(indexes)
            
        } else {
            var initialIndex = [Int]()
            initialIndex.append(index)
            
            RYUserDefaultCenter.recordIndex(initialIndex)
        }
    }
    
    static func clearIndex(at index: Int) {
        if var indexes = RYUserDefaultCenter.hasRecordedIndex(), indexes.count > 0 {
            
            indexes.removeAll { $0 == index }
            
            RYUserDefaultCenter.recordIndex(indexes)
        }
    }
}
