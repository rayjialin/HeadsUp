//
//  CafeModel.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit
import MapKit

@objcMembers
class CafeModel: NSObject, MKAnnotation{
    
//    let title: String
//    let urlString: String
    var coordinate: CLLocationCoordinate2D {
        return _coordinate
    }
     private var _coordinate: CLLocationCoordinate2D!

    init(dictionary: NSDictionary) {
       // print(dictionary["coordinates"]!)
        if let coordinate = dictionary["coordinates"] as? [String: Any] {
            let lat = (coordinate["latitude"] as? CLLocationDegrees)!
            let lon = (coordinate["longitude"] as? CLLocationDegrees)!
            self._coordinate = CLLocationCoordinate2DMake(lat, lon)
        }
    }
    

}
