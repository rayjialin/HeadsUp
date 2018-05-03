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
    
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet var searchingView: UIView!
    @IBOutlet var profileView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        //self.mainMapView.userTrackingMode = MKUserTrackingMode.follow
        
        self.view.addSubview(self.searchingView)
        ViewLayoutConstraint.viewLayoutConstraint(self.searchingView, defaultView: self.defaultView)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            print("made it")
            self.mainMapView.showsUserLocation = true
            if let firstLocation = manager.location {
                self.currentLocation = firstLocation
                self.placeAnnotations()
            }
        }
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(self.currentLocation.coordinate, span)
            self.mainMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        print("here")
    }
    
    func placeAnnotations() -> Void {
        let dataManager = DataManager(currentLocation: self.currentLocation.coordinate)
        dataManager.locateCafe.fetchCafeData { (cafeAnnotation) in
            var annotationArray: [MKAnnotation] = dataManager.dataAnnotations()
            annotationArray.append(cafeAnnotation)
            self.mainMapView.addAnnotations(annotationArray)
            self.mainMapView.showAnnotations(annotationArray, animated: true)
            
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
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
