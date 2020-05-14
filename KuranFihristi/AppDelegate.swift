//
//  AppDelegate.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
//import FirebaseInstanceID
//import FirebaseMessaging
import BackgroundTasks
//import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    
    private let defaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
//        registerForRichNotifications()
        
//        createTaskScherluder ()
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func registerForRichNotifications() {

       UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted:Bool, error:Error?) in
            if error != nil {
                print(error?.localizedDescription ?? "----")
            }
            if granted {
                self.defaults.set(true, forKey: "permissionNotification")
                print("Permission granted")
            } else {
                print("Permission not granted")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
        let action1 = UNNotificationAction(identifier: "action1", title: "show_in_verse".localized, options: [.foreground])

        let category = UNNotificationCategory(identifier: "actionCategory", actions: [action1], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([category])
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let chapterIdString = userInfo["chapterId"] as? String {
            defaults.set(Int(chapterIdString), forKey: "notificationChapterId")
        }
        if let verseIdString = userInfo["verseId"] as? String {
            defaults.set(Int(verseIdString), forKey: "notificationVerseId")
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    
    // background scherluder
//    func createTaskScherluder () {
//        BGTaskScheduler.shared.register(
//          forTaskWithIdentifier: "com.fihrist.heca.QuranFihristi.RandomAyat",
//          using: nil) { (task) in
//            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
//        }
//    }
//    
//    func handleAppRefreshTask(task: BGAppRefreshTask) {
//        task.expirationHandler = {
//            print("task runnuing")
//            let dataBase = DataBase()
//            let defaults = UserDefaults.standard
//            
//            var translationId = defaults.integer(forKey: "translationId")
//            if translationId == 0 {
//                translationId = 154
//            }
//            let verseBy = dataBase.getRandomVerseBy(translationId: translationId)
//            
//            let content = UNMutableNotificationContent()
//            let requestIdentifier = "fihristNotification"
//
//            content.title = "\(verseBy.chapterId). \(verseBy.chapterName), \(verseBy.verseId)"
//            content.body = verseBy.verseText
//            content.categoryIdentifier = "actionCategory"
//            content.userInfo = ["chapterId": "\(verseBy.chapterId)", "verseId": "\(verseBy.verseId)"]
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
//
//            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
//            UNUserNotificationCenter.current().add(request) { (error:Error?) in
//
//                if error != nil {
//                    print(error?.localizedDescription ?? "some unknown error")
//                }
//                print("Notification Register Success")
//            }
//            
//        }
//    }
    
    

}
// for push notifaction
// https://www.youtube.com/watch?v=SB2MFPUhmHw&t=609s

// background task
// https://www.andyibanez.com/posts/modern-background-tasks-ios13/
