//
//  RYCoachManager.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/15.
//  Copyright © 2019 RuiYu. All rights reserved.
//
/*
    Abstract: Manages the core of implement guides of user interface.
 */

import Foundation


struct RYCoachManager {
    
//    func showGuide(for views: [UIView]?, hints: [String]?, completion: @escaping ((UIView) -> Void)? = nil) -> Bool {
//
//    }
    
    
    /// Show guides for user interface.
    /// - Parameters:
    ///  - views: A array includes views that need to guide.
    ///  - hints: A array includes texts that need to presented when guiding.
    ///  - completion: A block which call back when guiding is finished.
    static func showGuide(for views: [UIView]?, hints: [String]?, completion: ((UIView?) -> Void)? = nil) -> RYCoachMarksView? {
        guard let views = views, views.count > 0,
            let hints = hints, hints.count > 0 else {
            return nil
        }
        
        if let app = UIApplication.shared.delegate as? AppDelegate,
            let mainWindow = app.window {
            let coach = RYCoachMarksView(frame: mainWindow.frame)
            coach.isShowHoles = true
            coach.holes = views
            coach.texts = hints
            if let completion = completion {
                coach.block = completion
            }
            
            // show and animate
            mainWindow.addSubview(coach)
            coach.animateGuides()
        
            return coach
        }
        
        return nil
    }
}
