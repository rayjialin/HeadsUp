//
//  DataManager.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    var user: User
    var matchedUsers: MatchUsers
    var user2: User
    var locateCafe: LocateCafe
    
    init(currentLocation: CLLocationCoordinate2D) {
        self.user = User(name: "Bob", coordinate: currentLocation)
        self.matchedUsers = MatchUsers.init(user: user)
        self.user2 = matchedUsers.findClosestUser()!
        self.locateCafe = LocateCafe(currentUser: user, otherUser: user2)
        locateCafe.fetchCafeData()
    
    }
    func dataAnnotations() -> [MKAnnotation] {
        var array = [MKAnnotation]()
        array.append(self.locateCafe)
        array.append(self.user2)
        
        return array
    }

}
