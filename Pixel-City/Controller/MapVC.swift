//
//  ViewController.swift
//  Pixel-City
//
//  Created by Sadman Sakib Saumik on 12/2/17.
//  Copyright © 2017 Sadman Sakib Saumik. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius:Double = 1000
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubletap()
    
    }
    
    func addDoubletap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    @IBAction func centerMapButtonTapped(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerToLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        removePin()
        let touchPoint = sender.location(in: mapView)
        //print(screenCoordinate)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        //The default annotation
        /*let annotation = MKPointAnnotation()
        annotation.coordinate = touchCoordinate*/
        
        //Custom Annotation
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        mapView.setCenter(touchCoordinate, animated: true)  // this seems a better option
        
       /* let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true) */
    }
    
    func removePin() {
        mapView.removeAnnotations(mapView.annotations) // this seems a better option
        /*for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }*/
    }
    
    func centerToLocation() {
        guard let location = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius*2, regionRadius*2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices(){
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            centerToLocation()
            return
        }
    }
}

