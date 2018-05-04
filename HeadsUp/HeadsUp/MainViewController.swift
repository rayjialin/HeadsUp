//
//  MainViewController.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit
import MapKit
import GeoFire
import Firebase

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mainMapView: MKMapView!
    var locationManager = CLLocationManager()
    var dataManager: DataManager?
    var currentLocation: CLLocation = CLLocation()
    var user: User?
    
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet var searchingView: UIView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var waitingView: UIView!
    @IBOutlet var startTalkingView: UIView!
    @IBOutlet var talkingView: UIView!
    @IBOutlet var timerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 5;
        //self.mainMapView.userTrackingMode = MKUserTrackingMode.follow
        
        self.view.addSubview(self.profileView)
        ViewLayoutConstraint.viewLayoutConstraint(self.profileView, defaultView: self.defaultView)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            print("made it")
            self.locationManager.startUpdatingLocation()
            self.mainMapView.showsUserLocation = true
            if let firstLocation = manager.location {
                self.currentLocation = firstLocation
            }
            self.user = User(name: "Brian", coordinate: self.currentLocation.coordinate)
            guard let user = self.user else {return}
            self.dataManager = DataManager(user: user)
        }
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
            self.mainMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("here")
        if let udid = UserDefaults.standard.value(forKey: "MY_UUID") as? String, !udid.isEmpty {
            // Use it...
            self.user?.saveLocGeoFire(uuid: udid)
            
            
            // RETRIEVE USERS PROFILE DATA
            self.user?.geofireRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                // Use Geofire query with radius to find locations in the area.
                let center = CLLocation(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude)
                let geoFire = GeoFire(firebaseRef: Database.database().reference(withPath: "User_Location"))
                let circleQuery = geoFire.query(at: center, withRadius: 10.6)
                
                var queryHandle = circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                    print("Key '\(key)' entered the search area and is at location '\(location)'")
                    if self.currentLocation.coordinate.latitude != location.coordinate.latitude && self.currentLocation.coordinate.longitude != location.coordinate.longitude {
                    guard let userDict = value else {return}
                    guard let singleDict = userDict[key] as? NSDictionary else {return}
                    guard let name = singleDict["name"] as? String else {return}
                    let nearbyUser = User(name: name, coordinate: location.coordinate)
                   // self.dataManager?.usersArray.append(nearbyUser)
                    self.dataManager?.addNearbyUser(newUser: nearbyUser)
                         self.placeAnnotations()
                    }
                })
                
                circleQuery.observeReady({
                    print("All initial data has been loaded and events have been fired!")
                    
                })
            })
        
        } else {
            let udid = UUID().uuidString
            UserDefaults.standard.set(udid, forKey: "MY_UUID")
        }
    
    }
    
    func placeAnnotations() -> Void {
        self.dataManager?.dataAnnotations(completion: { (annotationArray) in
            self.dataManager?.locateCafe?.fetchCafeData { (cafeAnnotation) in
                self.mainMapView.addAnnotation(cafeAnnotation)
            }
            self.mainMapView.addAnnotations(annotationArray)
            self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)
        })
        
        print("ODFKSODKSOFSDKSOFOSDKFOSDOS")
        print(#line, self.mainMapView.annotations.count)
        
        /*
         * Enables all annotations to fit on the screen.
         * code taken from https://gist.github.com/andrewgleave/915374
         */
        
        var zoomRect: MKMapRect = MKMapRectNull
        for annotation in self.mainMapView.annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = pointRect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
            }
        }
        self.mainMapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(15, 15, 15, 15), animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
