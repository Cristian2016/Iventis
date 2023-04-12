//
//  AppDelegate.swift
//  Timers
//
//  Created by Cristian Lapusan on 09.04.2023.
//https://stackoverflow.com/questions/65782435/receive-local-notifications-within-own-app-view-or-how-to-register-a-unuserno

import SwiftUI
import MyPackage

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    let snoozes = [5, 10, 15, 30, 60]
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Here we actually handle the notification
        print("Notification received with identifier \(notification.request.identifier)")
        // So we call the completionHandler telling that the notification should display a banner and play the notification sound - this will happen while the app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        /*
         here I decide how to handle user intents
         ex:
         1.if user taps notification -> UNNotificationDefaultActionIdentifier case
         2.user wants to repeat timer it's "repeat timer" action
         */
                
        let timerID = self.getTimerID(from: response) //which timer was it
        
        switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier: //user taps notification
                
                let name = Notification.Name("scrollToTimer")
                let info = ["scrollRank" : timerID]
                
                NotificationCenter.default.post(name: name, object: nil, userInfo: info)
                
            case "repeat timer" :
                print("repeat timer")
                
            default:
                print(response.actionIdentifier, " actionIdentifier")
                break
        }
                
        completionHandler() //notify system
    }

    // MARK: helpers
    private func getTimerID(from response:UNNotificationResponse) -> String {
        response.notification.request.identifier
    }
}
