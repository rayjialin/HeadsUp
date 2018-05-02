//
//  User.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit

class User: NSObject, MKAnnotation {
    
    let name: String
    var coordinate: CLLocationCoordinate2D
    //let matchedUser: MatchUsers
    let isMatched: Bool
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name;
        self.coordinate = coordinate;
        self.isMatched = false
    }

}
