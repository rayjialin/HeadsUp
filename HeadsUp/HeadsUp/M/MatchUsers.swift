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
    
    class func findClosestUser(user: User, userArray: [User]) -> User? {
         var shortestDistance = user.coordinate.distance(from: userArray[0].coordinate)
        var matchedUser = userArray[0];
        
        for otherUser in userArray {
            let selfDistance = user.coordinate
            
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
