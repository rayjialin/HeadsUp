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
    var userArray: [User]

    var user1 = User(name: "Brian", coordinate: CLLocationCoordinate2DMake(49.282000, -123.107234))
    var user2 = User(name: "Ray", coordinate: CLLocationCoordinate2DMake(49.278304, -123.111654))
    var user3 = User(name: "Sam", coordinate: CLLocationCoordinate2DMake(49.287094, -123.125430))
    
    
    
    init(user: User) {
        self.user = user;
        self.userArray = [user2, user1, user3];
    }
    
    func findClosestUser() -> User? {
        var shortestDistance: CLLocationDistance?
        
        
        for otherUser in self.userArray {
            if let selfDistance = self.user.coordinate, let otherDistance = otherUser.coordinate{
                
                if (shortestDistance == nil) {
                    shortestDistance = (selfDistance.distance(from: otherDistance))
                    print("initial shortest distance: \(shortestDistance!)")
                }
           
                if let unwrappedDistance = shortestDistance {
                    if (unwrappedDistance >  (selfDistance.distance(from: otherDistance))) {
                        shortestDistance = (selfDistance.distance(from: otherDistance))
                        print(shortestDistance!)
                    }
                }
            }
        }
        return nil
        
    }

}
