//
//  RYAdsRecorder.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/5/21.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation

class RYAdsRecorder {
    
    static let shared = RYAdsRecorder()
    
    var shownAds: Set<Int> = []
    
    func hasShownAd(for adid: Int) -> Bool {
        if RYAdsRecorder.shared.shownAds.contains(adid) {
            return true
        }
        return false
    }
    
    func showAd(for adid: Int) {
        RYAdsRecorder.shared.shownAds.insert(adid)
    }
    
    /// invoke when app is "applicationDidEnterBackground" in appdelegate.
    func clearAdsShown() {
        if RYAdsRecorder.shared.shownAds.count > 0 {
            RYAdsRecorder.shared.shownAds.removeAll()
        }
    }
}
