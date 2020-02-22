//
//  AppDelegate.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/3/26.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import Toast_Swift
import UserNotifications
import CryptoSwift
import MDAd
import BUAdSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 0. custom webview user agent
        RYWebView.configCustomUserAgent()
        
        // 1. register thirdpaties
        // 1.1 jPush
        // TODO: - apsForProduction need to be modified to TRUE when submitting to review.
        JPUSHService.setup(withOption: launchOptions,
                           appKey: "a5b84c2d16a0142f5d4042e4",
                           channel: "Production",
                           apsForProduction: true)
        let entity = JPUSHRegisterEntity()
        entity.types = Int(JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        // 1.2 Ads
        // 1.2.1 MDAd
        RYAdMobCenter.center.setup("621112", appSecret: "537dab8740884583a82f2db97fbc6eb6")
        
        // 1.2.2 Chuan shan jia
        BUAdSDKManager.setAppID("5045272")
        
        // 1.3 wechat
        WXApi.registerApp("wx5dbe4ff4977061f7")
        
        // 1.4 QQ
        _ = TencentOAuth(appId: "101685202", andDelegate: self)
        
        // 1.5 Weibo
        WeiboSDK.registerApp("2459930224")
        
        // 2. set rootViewController
        window = UIWindow(frame: UIScreen.main.bounds)
        if let launchPage = RYLanuchPage.launchPage() {
            window?.rootViewController = launchPage
        }
        
        window?.makeKeyAndVisible()
        
        // 3. reset badge
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
    
    /// Register wechat/QQ/weibo delegate
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // handle QQ
        if TencentOAuth.canHandleOpen(url) {
            TencentOAuth.handleOpen(url)
        }
        
        // handle weibo
        if WeiboSDK.isCanShareInWeiboAPP() {
            WeiboSDK.handleOpen(url, delegate: self)
        }
        
        // handle wechat
        WXApi.handleOpen(url, delegate: self)
        
        return true
    }
    
    /// register device token for JPush
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    /// Present or Push to your home viewController.
    /// - Parameter viewController: presentingViewController.
    func gotoHomePage(from viewController: UIViewController) {
        let storyboard = UIStoryboard(storyboard: .Main)
        let typeList: RYNavigationController = storyboard.instantiateViewController()
        typeList.modalPresentationStyle = .fullScreen
        typeList.modalTransitionStyle = .crossDissolve
        viewController.present(typeList, animated: true, completion: nil)
    }
    
}

// MARK: - WXAppdelegate

extension AppDelegate: WXApiDelegate {
    
    /// - note: `errCode` always return 0 when excute share scene. see details: https://open.weixin.qq.com/cgi-bin/announce?action=getannouncement&key=11534138374cE6li&version=&lang=zh_CN&token=
    func onResp(_ resp: BaseResp!) {
        if let resp = resp as? SendAuthResp {
            RYThirdPartiesShareManager.wechatLoginAuthDidResponded(resp, appID: "wx5dbe4ff4977061f7", appSecret: "8b2aaf3da7bd0468e1b71f641af843b6")
        }
    }
    
    func onReq(_ req: BaseReq!) {
        if let req = req as? SendAuthReq {
            debugPrint(req.openID ?? "no openID")
            debugPrint(req.type)
        }
    }
}

// MARK: - QQ>TencentSessionDelegate

extension AppDelegate: TencentSessionDelegate {
    
    /// Delegates indicates that call backs after qq logins finished.
    
    func tencentDidLogin() {}
    
    func tencentDidNotLogin(_ cancelled: Bool) {}
    
    func tencentDidNotNetWork() {}
}

// MARK: - WeiboSDKDelegate

extension AppDelegate: WeiboSDKDelegate {
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if let response = response as? WBSendMessageToWeiboResponse {
            if response.statusCode == .success {
                debugPrint("分享成功")
            } else {
                debugPrint("分享失败")
            }
        }
    }
    
}


// MARK: - JPUSHRegisterDelegate

extension AppDelegate: JPUSHRegisterDelegate {
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        completionHandler()
    }
}
