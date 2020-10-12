//
//  AppDelegate.swift
//  ChessFirebase
//
//  Created by hyperactive on 22/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SocketIOManager.sharedInstance.disconnect()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        SocketIOManager.sharedInstance.disconnect()
    }
}


