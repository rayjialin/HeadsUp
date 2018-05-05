//
//  AppDelegate.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let geofireRef = Database.database().reference()
        let geoFire = GeoFire(firebaseRef: geofireRef.child("User_Location"))
        
        guard let uuid = UserDefaults.standard.value(forKey: "MY_UUID") as? String else {return}
        
        print("remove key")
        geoFire.setLocation(CLLocation(latitude: 0, longitude: 0), forKey: uuid)
        geofireRef.child("Users").child(uuid).child("agreedToMeet").removeValue()


    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let geofireRef = Database.database().reference()
        let geoFire = GeoFire(firebaseRef: geofireRef.child("User_Location"))
        
        guard let uuid = UserDefaults.standard.value(forKey: "MY_UUID") as? String else {return}
        print("remove key")

        geoFire.setLocation(CLLocation(latitude: 0, longitude: 0), forKey: uuid)
        geofireRef.child("Users").child(uuid).child("agreedToMeet").removeValue()

    }


}

