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
    var uuid: String?
    var matchedUserUUID = ""
    
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet var searchingView: UIView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var talkingView: UIView!
    @IBOutlet weak var meetButton: UIButton!
    @IBOutlet weak var meetCounter: UILabel!
    @IBOutlet weak var topicTextView: UITextView!
    @IBOutlet weak var startTalkingButton: UIButton!
    
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
        
        if profileView.isHidden == false{
        setupMeetObserver()
        }
        if talkingView.isHidden == false{
            setupStartObserver()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("here")
        if let udid = UserDefaults.standard.value(forKey: "MY_UUID") as? String, !udid.isEmpty {
            // Use it...
            self.user?.saveLocGeoFire(uuid: udid)
            Database.database().reference().child("User_Location").child(udid).child("l").updateChildValues(["0" : manager.location?.coordinate.latitude as Any, "1" : manager.location?.coordinate.longitude as Any])
            self.user?.saveLocGeoFire(uuid: udid)
     
            // RETRIEVE USERS PROFILE DATA
            self.user?.geofireRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
                let value = snapshot.value as? NSDictionary
                
                // Use Geofire query with radius to find locations in the area.
                guard let managerLocation = manager.location?.coordinate else { return }
                let center = CLLocation(latitude: managerLocation.latitude, longitude: managerLocation.longitude)

                let geoFire = GeoFire(firebaseRef: Database.database().reference(withPath: "User_Location"))
                let circleQuery = geoFire.query(at: center, withRadius: 5.0)
                
                var queryHandle = circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                    
                    //print("Key '\(key)' entered the search area and is at location '\(location)'")
                    if udid != key {
                        guard let userDict = value else {return}
                        guard let singleDict = userDict[key] as? NSDictionary else {return}
                        guard let name = singleDict["name"] as? String else {return}
                        let nearbyUser = User(name: name, coordinate: location.coordinate)
                        self.dataManager?.addNearbyUser(newUser: nearbyUser)
                        self.dataManager?.findClosestUser(completion: { (closestUser) in
                            self.user?.matchedUserUUID = key // add matched user UUID to check if matched user pressed button agreed to meet
                            self.searchingView.removeFromSuperview()
                            self.view.addSubview(self.profileView)
                            ViewLayoutConstraint.viewLayoutConstraint(self.profileView, defaultView: self.defaultView)
                            self.searchingView.isHidden = true
                            
                            // Place closestUser, closest Restuarant, and Midpoint annotation
                            self.placeAnnotations()
                        })
                    }
                })
                
                circleQuery.observe(.keyMoved, with: { (key: String!, location: CLLocation!) in
                   // print("Key '\(key)' entered the search area and is at location '\(location)'")
                    let geoFire = GeoFire(firebaseRef: Database.database().reference().child("User_Location"))
                    if self.user?.matchedUserUUID == key {
                        geoFire.getLocationForKey(key) { (geoLocation, error) in
                            guard let closestUser = self.dataManager?.closestUser else {return}
                            if (error != nil) {
                                print("An error occurred getting the location for \"user-location\": \(error?.localizedDescription)")
                            }
                            if let geoLocation = location {
                                closestUser.coordinate = geoLocation.coordinate
                                self.mainMapView.removeAnnotation(closestUser)
                                self.mainMapView.addAnnotation(closestUser)
                                self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)
                                
                            } else {
                                print("GeoFire does not contain a location for \"user-location\"")
                            }
                        }
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
            if self.mainMapView.annotations.count < 4 {
                self.mainMapView.addAnnotations(annotationArray)
            }
            print("-----\(self.mainMapView.annotations)")
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
            //print("ANNOTATIONVIEW CHANGED TO USERANNOTATION")
            //print(annotation.coordinate)
            annotationView?.image = UIImage(named: "userAnnotation")
        }
        if let midpointAnnotation = annotation as? LocateCafe {
           // print("ANNOTATIONVIEW CHANGED TO USERANNOTATION")
            annotationView?.image = UIImage(named: "midpointAnnotation")
        }
        if let restaurantAnnotation = annotation as? CafeModel {
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
                    self.user?.isObserving = true
                    
                    if let matchedUserUUID = self.user?.matchedUserUUID{
                        if snapshot.childSnapshot(forPath: matchedUserUUID).hasChild("agreedToMeet"){
                            let value = snapshot.childSnapshot(forPath: matchedUserUUID).value as? NSDictionary
                            guard let userDict = value else {return}
                            if let agreedToMeet = userDict["agreedToMeet"] as? Bool{
                                if agreedToMeet == true{
                                    self.profileView.removeFromSuperview()
                                    self.view.addSubview(self.talkingView)
                                    ViewLayoutConstraint.viewLayoutConstraint(self.talkingView, defaultView: self.defaultView)
                                    self.profileView.isHidden = true
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
    func setupMeetObserver(){
        
        self.user?.geofireRef.child("Users").observe(.value, with: { (snapshot) in
            guard let matchedUser = self.user?.matchedUserUUID else {return}
            
            guard let agreedToMeet = snapshot.childSnapshot(forPath: matchedUser).childSnapshot(forPath: "agreedToMeet").value as? Bool else {return}
            
            if agreedToMeet == true && self.user?.isObserving == true{
                self.profileView.removeFromSuperview()
                self.view.addSubview(self.talkingView)
                ViewLayoutConstraint.viewLayoutConstraint(self.talkingView, defaultView: self.defaultView)
                self.profileView.isHidden = true

            }
        })
    }
    
    func setupStartObserver(){
        
        self.user?.geofireRef.child("Users").observe(.value, with: { (snapshot) in
            guard let matchedUser = self.user?.matchedUserUUID else {return}
            
            guard let agreedToStart = snapshot.childSnapshot(forPath: matchedUser).childSnapshot(forPath: "agreedToStart").value as? Bool else {return}
            
            if agreedToStart == true && self.user?.isStarted == true{
                self.performSegue(withIdentifier: "timerSegue", sender: self)
            }
        })
    }
    
    // when users met up, enable the start talking button to start the timer
    @IBAction func handleStartTalking(_ sender: UIButton) {
        
        // add property to user on firebase to set "agreeToMeet" condition to True
        if let uuid = UserDefaults.standard.value(forKey: "MY_UUID") as? String{
            self.user?.geofireRef.child("Users").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(uuid){
                    self.user?.geofireRef.child("Users").child(uuid).updateChildValues(["agreedToStart": true])
                    
                    // update current user button state
                    self.startTalkingButton.alpha = 0.4
                    self.startTalkingButton.isEnabled = false
                    self.user?.isStarted = true
                    
                    if let matchedUserUUID = self.user?.matchedUserUUID{
                        if snapshot.childSnapshot(forPath: matchedUserUUID).hasChild("agreedToStart"){
                            let value = snapshot.childSnapshot(forPath: matchedUserUUID).value as? NSDictionary
                            guard let userDict = value else {return}
                            if let agreedToStart = userDict["agreedToStart"] as? Bool{
                                if agreedToStart == true{
                                    self.performSegue(withIdentifier: "timerSegue", sender: self)
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
    
    
}
