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
    
    var user: User
    var userArray: [User?]
    var shortestDistance: CLLocationDistance?

    var user1 = User(name: "Brian", coordinate: CLLocationCoordinate2DMake(49.282000, -123.107234))
    var user2 = User(name: "Ray", coordinate: CLLocationCoordinate2DMake(49.278304, -123.111654))
    var user3 = User(name: "Sam", coordinate: CLLocationCoordinate2DMake(49.287094, -123.125430))
    
    
    
    init(user: User) {
        self.user = user;
        self.userArray = [user2, user1, user3]
        guard let coordinate = userArray[0]?.coordinate else { return }
        self.shortestDistance = self.user.coordinate.distance(from: coordinate)
    }
    
    func findClosestUser() -> User? {
        guard let user = self.userArray.first else { return nil }
        var matchedUser = user;
        
        for otherUser in self.userArray {
            let selfDistance = self.user.coordinate
            guard let otherDistance = otherUser?.coordinate else { return nil }
            //let otherDistance = otherUser?.coordinate
            
            if let unwrappedDistance = self.shortestDistance {
                if (unwrappedDistance >  (selfDistance.distance(from: otherDistance))) {
                    self.shortestDistance = (selfDistance.distance(from: otherDistance))
                    print(self.shortestDistance!)
                    print("Matched user before: \(String(describing: matchedUser))")
                    matchedUser = otherUser
                    print("Matched user after: \(String(describing: matchedUser ?? nil))")
                }
            }
        }
        print("Matched user outside: \(String(describing: matchedUser))")
        return matchedUser
    }
    

}
