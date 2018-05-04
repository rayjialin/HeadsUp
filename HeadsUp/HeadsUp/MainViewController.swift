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

class MainViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mainMapView: MKMapView!
    var locationManager = CLLocationManager()
    var dataManager: DataManager?
    var currentLocation: CLLocation = CLLocation()
    var user: User?
    var restaurantAnnotation: LocateCafe?
    var uuid: String?
    var isObserving = 0
    
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet var searchingView: UIView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var waitingView: UIView!
    //    @IBOutlet var startTalkingView: UIView!
    @IBOutlet var talkingView: UIView!
    @IBOutlet var timerView: UIView!
    @IBOutlet weak var meetButton: UIButton!
    @IBOutlet weak var meetCounter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 5;
        //self.mainMapView.userTrackingMode = MKUserTrackingMode.follow
        
        self.view.addSubview(self.searchingView)
        ViewLayoutConstraint.viewLayoutConstraint(self.searchingView, defaultView: self.defaultView)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
            self.mainMapView.showsUserLocation = true
            if let firstLocation = manager.location {
                self.currentLocation = firstLocation
            }
            self.user = User(name: "Ray", coordinate: self.currentLocation.coordinate)
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
                        self.dataManager?.addNearbyUser(newUser: nearbyUser)
                        if self.dataManager?.closestUser != nil {
                            self.user?.matchedUserUUID = key // add matched user UUID to check if matched user pressed button agreed to meet
                            self.searchingView.removeFromSuperview()
                            self.view.addSubview(self.profileView)
                            ViewLayoutConstraint.viewLayoutConstraint(self.profileView, defaultView: self.defaultView)
                            
                            // listen to matched users action
                            self.actionObserver()
                            
                        }
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
                self.restaurantAnnotation = cafeAnnotation as? LocateCafe
            }
            self.mainMapView.addAnnotations(annotationArray)
            self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)
        })
        
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
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "myId"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        } else {
            annotationView?.annotation = annotation
        }
        
        if let userAnnotation = annotation as? User, self.dataManager?.closestUser == annotation as? User {
            annotationView?.image = UIImage(named: "userAnnotation-2")
        }
        if let midpointAnnotation = annotation as? LocateCafe {
            annotationView?.image = UIImage(named: "midpointAnnotation")
        }
        if let restaurantAnnotation = annotation as? LocateCafe, self.restaurantAnnotation == annotation as? LocateCafe {
            annotationView?.image = UIImage(named: "restaurantAnnotation")
        }
        
        annotationView?.frame = CGRect(x: 0, y: 0, width: 35, height: 40)
        
        return annotationView
    }
        
        
    @IBAction func startMeeting(_ sender: UIButton) {
        // add property to user on firebase to set "agreeToMeet" condition to True
        if let uuid = UserDefaults.standard.value(forKey: "MY_UUID") as? String{
            self.user?.geofireRef.child("Users").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(uuid){
                    self.user?.geofireRef.child("Users").child(uuid).updateChildValues(["agreedToMeet": true])
                    
                    // update current user button state
                    self.meetButton.alpha = 0.4
                    self.meetButton.isEnabled = false
                    self.isObserving = 1
                    
                    if let matchedUserUUID = self.user?.matchedUserUUID{
                        if snapshot.hasChild(uuid){
                            if snapshot.childSnapshot(forPath: matchedUserUUID).hasChild("agreedToMeet"){
                                let value = snapshot.childSnapshot(forPath: matchedUserUUID).value as? NSDictionary
                                guard let userDict = value else {return}
                                if let agreedToMeet = userDict["agreedToMeet"] as? Bool{
                                    if agreedToMeet == true{
                                        self.profileView.removeFromSuperview()
                                        self.view.addSubview(self.talkingView)
                                        ViewLayoutConstraint.viewLayoutConstraint(self.talkingView, defaultView: self.defaultView)
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                }
            }
        }
    }
    
    
    func actionObserver(){
        // track the agreedToMeet state on firebase
        if isObserving == 1{
            guard let matchedUserUUID = self.user?.matchedUserUUID else {return}
            self.user?.geofireRef.child("Users").child(matchedUserUUID).child("agreedToMeet").observe(.value , with: {snapshot in
                let agreedToMeet = snapshot.value as? Bool
                //
                if agreedToMeet == true{
                    self.profileView.removeFromSuperview()
                    self.view.addSubview(self.talkingView)
                    ViewLayoutConstraint.viewLayoutConstraint(self.talkingView, defaultView: self.defaultView)
                }
            })
        }
        
    }

}
    

