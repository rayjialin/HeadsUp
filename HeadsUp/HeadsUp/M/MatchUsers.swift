//
//  MatchUsers.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination = CLLocation(latitude: from.latitude, longitude: from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}

class MatchUsers: NSObject {
    
//    var user: User
//    var userArray: [User?]
//    var shortestDistance: CLLocationDistance?
//
//    var user1 = User(name: "Brian", coordinate: CLLocationCoordinate2DMake(49.282000, -123.107234))
//    var user2 = User(name: "Ray", coordinate: CLLocationCoordinate2DMake(49.278304, -123.111654))
//    var user3 = User(name: "Sam", coordinate: CLLocationCoordinate2DMake(49.287094, -123.125430))
//
//
//
//    init(user: User, usersArray: [User]) {
//        self.user = user;
//        self.userArray = usersArray
//        guard  usersArray.count > 0, let coordinate = userArray[0]?.coordinate else { return }
//        self.shortestDistance = self.user.coordinate.distance(from: coordinate)
//    }
    
    class func findClosestUser(user: User, userArray: [User]) -> User? {
        //guard let user = userArray.first else { return nil }
        var shortestDistance = user.coordinate.distance(from: userArray[0].coordinate)
        
        var matchedUser = userArray[0];
        
        for otherUser in userArray {
            let selfDistance = user.coordinate
            //guard let otherDistance = otherUser.coordinate else { return nil }
            //let otherDistance = otherUser?.coordinate
            
            //if let unwrappedDistance = shortestDistance {
            if (shortestDistance >  (selfDistance.distance(from: otherUser.coordinate))) {
                shortestDistance = (selfDistance.distance(from: otherUser.coordinate))
                print(shortestDistance)
                //print("Matched user before: \(String(describing: matchedUser))")
                matchedUser = otherUser
                //print("Matched user after: \(String(describing: matchedUser ?? nil))")
            }
        }
        print("Matched user outside: \(String(describing: matchedUser))")
        return matchedUser
    }
    

}
