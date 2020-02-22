//
//  RYIndexRecorder.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/11.
//  Copyright © 2019 RuiYu. All rights reserved.
//

/* Abstract:
 Need refactor with 'RYIndexPathRecorder.swift'.
 */

import Foundation


struct RYIndexRecorder {
    
    var records = Set<Int>()
    
    func isContainedIndex(at index: Int) -> Bool {
        if records.contains(index) {
            return true
        }
        return false
    }
    
    mutating func recordIndex(at index: Int) {
        records.insert(index)
    }
    
}
