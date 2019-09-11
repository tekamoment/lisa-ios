//
//  AppDelegate.swift
//  LISA
//
//  Created by Carlos Arcenas on 4/24/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import FacebookCore

import Fabric
import Crashlytics

import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var pushNotificationRegistrationDelegate: AppDelegatePushNotificationRegistrationDelegate? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Crashlytics.self])
//        registerForPushNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }

    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }

        }
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        // actually send shit here
        
        let apnsRequest = APNSRequest(registrationId: token)
        guard let loginDetails = CombinedUserInformation.shared.loginDetails(), let apnsRequestData = try? JSONEncoder().encode(apnsRequest) else {
            print("ERROR ERROR ERROR")
            return
        }
        
        let pushNotificationsRequest = NetworkRequest(url: URL(string: AppAPIBase.APNSRegistrationPath)!, method: .POST, data: apnsRequestData, headers: AppAPIBase.standardHeaders(withToken: loginDetails.accessToken))
        pushNotificationsRequest.execute { (data) in
            guard let data = data else {
                self.pushNotificationRegistrationDelegate?.registrationForPushNotificationsCompleted(success: false)
                return
            }
            
            print(String(data: data, encoding: .utf8))
            
        self.pushNotificationRegistrationDelegate?.registrationForPushNotificationsCompleted(success: true)
            
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
        pushNotificationRegistrationDelegate?.registrationForPushNotificationsCompleted(success: false)
    }
}

protocol AppDelegatePushNotificationRegistrationDelegate: class {
//    func registration
    func registrationForPushNotificationsCompleted(success: Bool)
}
