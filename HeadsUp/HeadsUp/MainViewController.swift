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
    var currentLocation: CLLocation = CLLocation()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
//        let networkManager = NetworkManager()
//        networkManager.fetchCafes(withUserLocation: (self.currentLocation?.coordinate)!, searchTerm: nil) { (cafes) in
//            print(cafes!)
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            print("made it")
            self.mainMapView.showsUserLocation = true
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
            //self.mainMapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if self.currentLocation == nil {
//            self.currentLocation = locations.first
//            self.mapView.showsUserLocation = true
//        }
        print("here")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
