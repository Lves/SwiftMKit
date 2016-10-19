
//  AppDelegate.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/14/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack
import MagicalRecord
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        setenv("XcodeColors", "YES", 0);
        DemoNetworkConfig.Release = false
        DemoNetworkConfig.Evn = .Product
        DDLog.setup(.Debug)
        DDTTYLogger.sharedInstance().logFormatter = DDLogMKitFormatter()
        MagicalRecord.setShouldDeleteStoreOnModelMismatch(true)
        MagicalRecord.setupCoreDataStack()
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        NetApiClient.shared.startNotifyNetworkStatus()
        NetApiClient.shared.initEncryptFramework("appid", vId: "vId")
        // debug时可显示加密库的log
//        EncryptedNetworkManager.setShowLog(true)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

