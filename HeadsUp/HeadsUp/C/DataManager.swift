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
//    var matchedUsers: MatchUsers
    var closestUser: User?
    var currentUser: User
    var locateCafe: LocateCafe?
    var usersArray = [User]()
    
    
    init(user: User) {
        self.currentUser = user
    }
    
    func addNearbyUser(newUser: User) {
        if !self.usersArray.contains(newUser) {
            self.usersArray.append(newUser)
        }
//        guard let closestUser = MatchUsers.findClosestUser(user: self.currentUser, userArray: usersArray) else { return }
//        self.closestUser = closestUser
//        self.currentUser.matchedUserUUID = self.closestUser
        
    }
    
    func findClosestUser(completion: @escaping (_ completion: User ) -> Void) {
        if let closestUser = MatchUsers.findClosestUser(user: self.currentUser, userArray: self.usersArray) {
            DispatchQueue.main.async {
                self.closestUser = closestUser
                completion(closestUser)
            }
        }
    }
    
    
    func dataAnnotations(completion: @escaping (_ completion: [MKAnnotation] ) -> Void) {
        var array = [MKAnnotation]()
        self.findClosestUser { (closestUser) in
            print("appending closest user annotation")
            array.append(closestUser)
            
            self.locateCafe = LocateCafe(currentUser: self.currentUser, otherUser: closestUser)
            if let midpoint = self.locateCafe {
                
                print("appending midpoint annotation")
                array.append(midpoint)
                
                midpoint.fetchCafeData { (cafeAnnotation) in
                    print("appending midpoint annotation")
                    array.append(cafeAnnotation)
                    DispatchQueue.main.async {
                        completion(array)
                    }
                }
            }
        }
    }
    

}
