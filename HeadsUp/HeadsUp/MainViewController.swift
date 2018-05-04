//
//  MainViewController.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit
import MapKit

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
        }
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
            self.mainMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("here")
//        self.user = User(name: "UserName", coordinate: self.currentLocation.coordinate)
        if let udid = UserDefaults.standard.value(forKey: "MY_UUID") as? String, !udid.isEmpty {
            // Use it...
            self.user?.saveLocGeoFire(uuid: udid)
            //self.user?.retrieveLocGeoFire(uuid: udid)
            
            
            // RETRIEVE USERS PROFILE DATA
            self.user?.geofireRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if let allKeys = value?.allKeys as? [String], allKeys.count > 0 {
                    for userUUID in allKeys {
                        self.user?.geofireRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
                            //self.user?.retrieveLocGeoFire(uuid: userUUID)
                            //var newUser = [
//                            self.dataManager?.usersArray?.append(<#T##newElement: User##User#>)
                        })
                    }
                }
            })
        
        } else {
            let udid = UUID().uuidString
            UserDefaults.standard.set(udid, forKey: "MY_UUID")
        }
        
        
        // Use Geofire query with radius to find locations in the area.
        let center = CLLocation(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude)
        var circleQuery = user?.geoFire.query(at: center, withRadius: 1000000000.6)
        
        // Query location by region
        let span = MKCoordinateSpanMake(0.001, 0.001)
        let region = MKCoordinateRegionMake(center.coordinate, span)
        let regionQuery = user?.geoFire.query(with: region)
        
        var queryHandle = regionQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' entered the search area and is at location '\(location)'")
        })
        
        regionQuery?.observeReady({
            print("All initial data has been loaded and events have been fired!")
            
        })
        
        
        self.placeAnnotations()
    
    }
    
    func placeAnnotations() -> Void {
        guard let user = self.user else {return}
        self.dataManager = DataManager(user: user)
        guard let dataAnnotations = self.dataManager?.dataAnnotations() else { return }
        var annotationArray: [MKAnnotation] = dataAnnotations
        self.dataManager?.locateCafe.fetchCafeData { (cafeAnnotation) in
            annotationArray.append(cafeAnnotation)
        }
        self.mainMapView.addAnnotations(annotationArray)
        self.mainMapView.showAnnotations(annotationArray, animated: true)
        
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
