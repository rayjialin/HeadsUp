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
    var image: UIImage? = UIImage()
    var name = String()
    var email = String()
    var phoneNumber = String()
    var timer = Timer()
    var seconds = 60

    
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet var searchingView: UIView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var talkingView: UIView!
    @IBOutlet weak var meetButton: UIButton!
    @IBOutlet weak var meetCounter: UILabel!
    @IBOutlet weak var topicTextView: UITextView!
    @IBOutlet weak var startTalkingButton: UIButton!
    @IBOutlet weak var meetDistanceLabel: UILabel!
    @IBOutlet weak var startDistanceLabel: UILabel!
    @IBOutlet weak var meetNameLabel: UILabel!
    @IBOutlet weak var startNameLabel: UILabel!
    @IBOutlet weak var meetProfileImageView: UIImageView!
    @IBOutlet weak var startProfileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 2;
        
        self.view.addSubview(self.searchingView)
        ViewLayoutConstraint.viewLayoutConstraint(self.searchingView, defaultView: self.defaultView)
        
        print("ANNOTATION COUNT: \(self.mainMapView.annotations.count)")
        //self.mainMapView.removeAnnotations(self.mainMapView.annotations)
        createUserProfile()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
            self.mainMapView.showsUserLocation = true
            if let firstLocation = manager.location {
                self.currentLocation = firstLocation
            }
            //            self.user = User(name: "Ray", coordinate: self.currentLocation.coordinate)
            guard let name = UserDefaults.standard.value(forKey: "name") as? String else {return}
            guard let imageUrl = UserDefaults.standard.value(forKey: "ProfileimageUrl") as? String else {return}
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return}
            guard let phoneNumber = UserDefaults.standard.value(forKey: "phoneNumber") as? String else {return}
            
            
            self.user = User(name: name, email: email, profileImageUrl: imageUrl, phoneNumber: phoneNumber, coordinate: self.currentLocation.coordinate)

            if let udid = UserDefaults.standard.value(forKey: "MY_UUID") as? String, !udid.isEmpty {
                self.user?.saveLocGeoFire(uuid: udid)
            } else {
                let udid = UUID().uuidString
                UserDefaults.standard.set(udid, forKey: "MY_UUID")
            }
            
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
        if let udid = UserDefaults.standard.value(forKey: "MY_UUID") as? String {
            //self.user?.saveLocGeoFire(uuid: udid)
            Database.database().reference().child("User_Location").child(udid).child("l").updateChildValues(["0" : manager.location?.coordinate.latitude as Any, "1" : manager.location?.coordinate.longitude as Any])
            // RETRIEVE USERS PROFILE DATA
            self.user?.geofireRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
                let value = snapshot.value as? NSDictionary
                
                // Use Geofire query with radius to find locations in the area.
                guard let managerLocation = manager.location?.coordinate else { return }
                let center = CLLocation(latitude: managerLocation.latitude, longitude: managerLocation.longitude)
                
                let geoFire = GeoFire(firebaseRef: Database.database().reference(withPath: "User_Location"))
                let circleQuery = geoFire.query(at: center, withRadius: 5.0)
                
                circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                    //print("Key '\(key)' entered the search area and is at location '\(location)'")
                    if udid != key {
                        guard let userDict = value else {return}
                        guard let singleDict = userDict[key] as? NSDictionary else {return}
                        guard let name = singleDict["name"] as? String else {return}
                        guard let phoneNUmber = singleDict["phoneNumber"] as? String else {return}
                        guard let email = singleDict["email"] as? String else {return}
                        guard let profileImage = singleDict["profileImage"] as? String else {return}
                        let nearbyUser = User(name: name, email: email, profileImageUrl: profileImage, phoneNumber: phoneNUmber, coordinate: location.coordinate)
                        //                        let nearbyUser = User(name: name, email: nil, profileImageUrl: nil, phoneNumber: nil, coordinate: location.coordinate)
                        self.dataManager?.addNearbyUser(newUser: nearbyUser)
                        if self.dataManager?.closestUser == nil {
                        self.dataManager?.findClosestUser(completion: { (closestUser) in
                            self.user?.matchedUserUUID = key // add matched user UUID to check if matched user pressed button agreed to meet
                            self.searchingView.removeFromSuperview()
                            self.view.addSubview(self.profileView)
                            ViewLayoutConstraint.viewLayoutConstraint(self.profileView, defaultView: self.defaultView)
                            //self.searchingView.isHidden = true
                            
                            self.meetNameLabel.text = closestUser.name
                            self.updateDistanceLabels(label: self.meetDistanceLabel, managerLocation: managerLocation, closestUser: closestUser)
                            
                            UserDefaults.standard.set(self.user?.matchedUserUUID, forKey: "closestUserUUID")
                            UserDefaults.standard.set(closestUser.name, forKey: "CLOSEST_USER")
                            UserDefaults.standard.set(closestUser.profileImageUrl, forKey: "closestUserImageUrl")
                            UserDefaults.standard.set(closestUser.phoneNumber, forKey: "closestUserPhoneNumber")
                            
                            // Place closestUser, closest Restuarant, and Midpoint annotation
                            self.placeAnnotations()
                        })
                    }
                    }
                })
                
                circleQuery.observe(.keyMoved, with: { (key: String!, location: CLLocation!) in
                    // print("Key '\(key)' entered the search area and is at location '\(location)'")

                    let geoFire = GeoFire(firebaseRef: Database.database().reference().child("User_Location"))
                    if self.user?.matchedUserUUID == key {
                        geoFire.getLocationForKey(key) { (geoLocation, error) in
                            if (error != nil) {
                                print("An error occurred getting the location for \"user-location\": \(error?.localizedDescription)")
                            }
                            if let geoLocation = geoLocation {
                                guard let closestUser = self.dataManager?.closestUser else {return}
                                 let updateClosestUserAnnotation = closestUser
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.mainMapView.removeAnnotation(closestUser)
                                    updateClosestUserAnnotation.coordinate = geoLocation.coordinate
                                    self.mainMapView.addAnnotation(updateClosestUserAnnotation)
                                }, completion: nil)
                                
                                self.updateDistanceLabels(label: self.startDistanceLabel, managerLocation: managerLocation, closestUser: updateClosestUserAnnotation)
                                
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
            
        }
    }
    
    func placeAnnotations() -> Void {
        if self.mainMapView.annotations.count < 4 {
            self.dataManager?.dataAnnotations(completion: { (annotationArray) in
                print("ADDING ANNOTATIONARRAY USER")
                 if self.mainMapView.annotations.count < 4 {
                    self.mainMapView.addAnnotations(annotationArray)
                    self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)
                }
                
                print("-----\(self.mainMapView.annotations)")
            })
        }
        
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
        
        if self.dataManager?.closestUser == annotation as? User {
            //print("ANNOTATIONVIEW CHANGED TO USERANNOTATION")
            print(annotation.coordinate)
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
    
    // When I press the MEET Button
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
                    
                    
                    // MatchedUser also presses the MEET button
                    if let matchedUserUUID = self.user?.matchedUserUUID{
                        if snapshot.childSnapshot(forPath: matchedUserUUID).hasChild("agreedToMeet"){
                            let value = snapshot.childSnapshot(forPath: matchedUserUUID).value as? NSDictionary
                            guard let userDict = value else {return}
                            if let agreedToMeet = userDict["agreedToMeet"] as? Bool{
                                if agreedToMeet == true{
                                    self.profileView.removeFromSuperview()
                                    self.view.addSubview(self.talkingView)
                                    ViewLayoutConstraint.viewLayoutConstraint(self.talkingView, defaultView: self.defaultView)
                                    self.startNameLabel.text = self.dataManager?.closestUser?.name
                                    
                                    
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
            
            // When Matched User DOESNT agree then reset the closestUser & button
            if agreedToMeet == false && self.user?.isObserving == true || agreedToMeet == true && self.user?.isObserving == false {
                self.runTimer()
            }

            // When matchedUser agrees to MEET *FIRST* and I agree
            if agreedToMeet == true && self.user?.isObserving == true{
                self.timer.invalidate()
                self.profileView.removeFromSuperview()
                self.view.addSubview(self.talkingView)
                ViewLayoutConstraint.viewLayoutConstraint(self.talkingView, defaultView: self.defaultView)
                self.startNameLabel.text = self.dataManager?.closestUser?.name
                self.displayRandomTopic()
                
                if let myCoordinate = self.locationManager.location?.coordinate, let closestUser = self.dataManager?.closestUser {
                    self.updateDistanceLabels(label: self.startDistanceLabel, managerLocation: myCoordinate, closestUser: closestUser)
                }
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
    
    func updateDistanceLabels(label: UILabel, managerLocation: CLLocationCoordinate2D, closestUser: User) {
        if managerLocation.distance(from: closestUser.coordinate) >= 1000 {
            label.text = String(format: "%.0f km", managerLocation.distance(from: closestUser.coordinate) / 1000)
        } else {
            label.text =  String(format: "%.0f m", managerLocation.distance(from: closestUser.coordinate))
        }
    }

    func displayRandomTopic(){
        let randomTopicNumber = String(arc4random_uniform(5))
        self.user?.geofireRef.child("Topics").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(randomTopicNumber){
                DispatchQueue.main.async {
                    self.topicTextView.text = "suggested topic:\n\(snapshot.childSnapshot(forPath: randomTopicNumber).value as? String ?? "Say anything you want")"
                    self.topicTextView.isHidden = false
                }
            }
        })
    }
        

    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            //renew()
        } else {
            seconds -= 1
            meetCounter.text = timeString(time: TimeInterval(seconds))
        }
    }
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%01i:%02i", minutes, seconds)
    }
    
    func renew() {
        // RESET DATA
        self.timer.invalidate()
        seconds = 60
        self.user?.isObserving = false
        if let closestUser = self.dataManager?.closestUser {
            if let index = self.dataManager?.usersArray.index(of: closestUser) {
                self.dataManager?.usersArray.remove(at: index)
                self.dataManager?.closestUser = nil
            }
        }
        self.mainMapView.removeAnnotations(self.mainMapView.annotations)
        
        
        // RELOAD APP & Firebase
        if let uuid = UserDefaults.standard.value(forKey: "MY_UUID") as? String {
            Database.database().reference().child("Users").child(uuid).updateChildValues(["agreedToMeet": false,
                                                                                          "agreedToStart": false,
                                                                                         "showPhoneNumber": false])
        }
        if let matchUserUUID = self.user?.matchedUserUUID {
            Database.database().reference().child("Users").child(matchUserUUID).updateChildValues(["agreedToMeet": false,
                                                                                                   "agreedToStart": false,
                                                                                                   "showPhoneNumber": false])
        }
//        self.user?.matchedUserUUID = ""
        UIApplication.shared.keyWindow?.rootViewController = storyboard!.instantiateViewController(withIdentifier: "Root_View")
    }
    
    
    func createUserProfile(){
        
        if let uuid = UserDefaults.standard.value(forKey: "MY_UUID") as? String {
            if uuid == "5A88BD2B-B18D-46C4-9CBA-628C738ED874" || uuid == "849A01AA-2F57-4438-BAAA-70B7F2FAB975"{
                self.startProfileImageView.image = #imageLiteral(resourceName: "brian")
                self.meetProfileImageView.image = #imageLiteral(resourceName: "brian")
                image = #imageLiteral(resourceName: "brian")
                name = "Brian"
                email = "brianLHL@gmail.com"
                phoneNumber = "778-456-9037"
            }else if uuid == "C86474A7-DE27-4B1B-A5BF-186FDF648622" || uuid == "4CFFA45B-BBB8-4E7C-99D6-FA453669C269"{
                self.startProfileImageView.image = #imageLiteral(resourceName: "ray")
                self.meetProfileImageView.image = #imageLiteral(resourceName: "ray")
                image = #imageLiteral(resourceName: "ray")
                name = "Ray"
                email = "rayLHL@gmail.com"
                phoneNumber = "778-392-1701"
            }
            guard let image = image else {return}
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(image){
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if let error = error{
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        self.user?.profileImageUrl = profileImageUrl
                        self.user?.name = self.name
                        self.user?.email = self.email
                        self.user?.phoneNumber = self.phoneNumber
                        
                        UserDefaults.standard.set(profileImageUrl, forKey: "ProfileimageUrl")
                        UserDefaults.standard.set(self.email, forKey: "email")
                        UserDefaults.standard.set(self.phoneNumber, forKey: "phoneNumber")
                        UserDefaults.standard.set(self.name, forKey: "name")
                        
                        let userRef = Database.database().reference().child("Users").child(uuid)
                        userRef.updateChildValues(["name": self.user?.name])
                        userRef.updateChildValues(["email": self.user?.email])
                        userRef.updateChildValues(["profileImage": self.user?.profileImageUrl])
                        userRef.updateChildValues(["phoneNumber": self.user?.phoneNumber])
                    }
                }
            }
        }
    }
    
    class func downloadProfileImage(imageUrl: String, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: imageUrl) else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
}
