//
//  LocateCafe.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import Foundation



class LocateCafe: NSObject, MKAnnotation {
    
    var currentUser: User
    var otherUser: User
    var coordinate: CLLocationCoordinate2D {
        return _coordinate
    }
    private var _coordinate: CLLocationCoordinate2D!
    
    init(currentUser: User, otherUser: User) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init()
        self._coordinate = findCenterPoint(_lo1: self.currentUser.coordinate, _loc2: self.otherUser.coordinate)
        print("cordinate is: \(self._coordinate)")
    }
    
    func findCenterPoint(_lo1: CLLocationCoordinate2D, _loc2:CLLocationCoordinate2D) -> CLLocationCoordinate2D {

    let lon1 = _lo1.longitude * Double.pi / 180;
    let lon2 = _loc2.longitude * Double.pi / 180;

    let lat1 = _lo1.latitude * Double.pi / 180;
    let lat2 = _loc2.latitude * Double.pi / 180;

    let dLon = lon2 - lon1;

    let x = cos(lat2) * cos(dLon);
    let y = cos(lat2) * sin(dLon);

    let lat3 = atan2(sin(lat1) + sin(lat2),
                    sqrt((cos(lat1) + x) * ((cos(lat1) + x) + y * y)));
    let lon3 = lon1 + atan2(y, cos(lat1) + x);

        var center = CLLocationCoordinate2D()
        center.latitude  = lat3 * 180 / Double.pi;
        center.longitude = lon3 * 180 / Double.pi;
        print(center)
        return center
    }

    func fetchCafeData(completion: @escaping (_ completion: MKAnnotation) -> Void) {
        let midPointLocation = findCenterPoint(_lo1: self.currentUser.coordinate, _loc2: self.otherUser.coordinate)
        let networkManager = NetworkManager()
        networkManager.fetchCafes(withUserLocation: midPointLocation, radius: 100) { (cafes) in
            
            if let unwrappedCafe = cafes as? [CafeModel] {
                DispatchQueue.main.async {
//                    cafeLocation = unwrappedCafe[0].coordinate
                    completion(unwrappedCafe[0])
                    //print("cafelocation inside \(cafeLocation)")
                    
                }
            }
        }
    }
}
