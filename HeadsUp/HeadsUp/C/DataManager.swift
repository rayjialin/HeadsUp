//
//  DataManager.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class DataManager: NSObject {
    
    //var user: User
    var matchedUsers: MatchUsers
    var user2: User
    var locateCafe: LocateCafe
    var usersArray: [User]? = nil
//    var geofireRef: DatabaseReference
//    var geoFire: GeoFire
    
    init(user: User) {
        //self.user = User(name: "Bob", coordinate: currentLocation)
        self.matchedUsers = MatchUsers(user: user)
        self.user2 = matchedUsers.findClosestUser()!
        self.locateCafe = LocateCafe(currentUser: user, otherUser: user2)
//        self.geofireRef = Database.database().reference()
//        self.geoFire = GeoFire(firebaseRef: self.geofireRef)
    }
    
    
    func dataAnnotations() -> [MKAnnotation] {
        var array = [MKAnnotation]()
        array.append(self.locateCafe)
        array.append(self.user2)
        return array
    }
    

}
