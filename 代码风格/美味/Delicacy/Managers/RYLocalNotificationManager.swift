//
//  RYLocalNotificationManager.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/4/3.
//  Copyright © 2019 RuiYu. All rights reserved.
//

/*
    Abstract: Manages local notifications.
 */

import Foundation
import UserNotifications


class RYLocalNotificationManager: NSObject {
    
    init(_ delegate: AppDelegate) {
        super.init()
        
        // request authorization
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) { bool, error in
            if bool {
                center.delegate = delegate
            }
        }
        
        // config notification
        
        configNotification()
    }
    
    func configNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "吃货也讲究"
        content.body = "今天的饮食计划, 你安排好了吗?"
        content.badge = NSNumber(value: 1)
        
//        content.launchImageName = "icon-20"
        var component = DateComponents()
        component.hour = 8
        component.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: true)
        
        let request = UNNotificationRequest(identifier: "RequestIdentifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            debugPrint(error ?? "notificationCenter request without Error")
        }
    }
}
