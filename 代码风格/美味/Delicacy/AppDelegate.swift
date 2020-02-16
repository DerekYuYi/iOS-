//
//  AppDelegate.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/20.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit
import Toast_Swift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 0. custom webview user agent
        RYWebPage.configCustomUserAgent()
        
        // 1. register third-parties
        // 1.1 register wechat
        WXApi.registerApp("wx67935899de074c73")
        
        // 1.2 register JPush
        // TODO: - apsForProduction need to be modified to TRUE when submitting to review.
        JPUSHService.setup(withOption: launchOptions,
                           appKey: "58049a984cdd4c7707a35243",
                           channel: "Production",
                           apsForProduction: true)
        let entity = JPUSHRegisterEntity()
        entity.types = Int(JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        
        // 2. Config toast basic UI.
        ToastManager.shared.style.backgroundColor = UIColor.groupTableViewBackground
        ToastManager.shared.style.cornerRadius = 5.0
        ToastManager.shared.style.titleFont = RYFormatter.fontLarge(for: .bold)
        ToastManager.shared.style.titleColor = .black
        ToastManager.shared.style.messageColor = .black
        ToastManager.shared.style.activityBackgroundColor = UIColor.black.withAlphaComponent(0.25)
        
        // 3. set rootViewController
        window = UIWindow(frame: UIScreen.main.bounds)
        if let launchPage = RYLanuchPage.launchPage() {
            window?.rootViewController = launchPage
        }
        
        window?.makeKeyAndVisible()
        
        // 4. handle badge number
        application.applicationIconBadgeNumber = 0
        JPUSHService.resetBadge()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        RYAdsRecorder.shared.clearAdsShown()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /*
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    */
    
    /// Register wechat delegate
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    /// register device token for JPush
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    /// Present or Push to your home viewController.
    /// - Parameter viewController: presentingViewController
    func gotoHomePage(from viewController: UIViewController) {
        if let tabBarVC = UIStoryboard.mainStoryboard_starter() {
            tabBarVC.modalTransitionStyle = .crossDissolve
            viewController.present(tabBarVC, animated: true, completion: nil)
        }
    }
}

// MARK: - WXAppdelegate

extension AppDelegate: WXApiDelegate {
    
    /// - note: `errCode` always return 0 when excute share scene. see details: https://open.weixin.qq.com/cgi-bin/announce?action=getannouncement&key=11534138374cE6li&version=&lang=zh_CN&token=
    func onResp(_ resp: BaseResp!) {
        if let resp = resp as? SendAuthResp {
            RYWechatManager.wechatLoginAuthDidResponded(resp, appID: "wx67935899de074c73", appSecret: "f9335f2c6790ef56c9a994fa400d292e")
        }
    }
    
    func onReq(_ req: BaseReq!) {
        if let req = req as? SendAuthReq {
            debugPrint(req.openID ?? "no openID")
            debugPrint(req.type)
        }
    }
}


// MARK: - UNUserNotificationCenterDelegate (for local notification)

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
}

// MARK: - JPUSHRegisterDelegate (for remote notification)

extension AppDelegate: JPUSHRegisterDelegate {
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        completionHandler()
    }
}


