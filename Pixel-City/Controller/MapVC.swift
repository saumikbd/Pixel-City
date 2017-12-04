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
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var spinner:UIActivityIndicatorView?
    var progressLabel: UILabel?
    
    
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
    func addSwipeDown(){
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownPullUpView))
        swipeDown.direction = .down
        pullUpView.addGestureRecognizer(swipeDown)
    }
    
    @objc func swipeDownPullUpView(){
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    func animatePullUpViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner?.center = CGPoint(x: view.frame.size.width/2 - (spinner?.frame.size.width)!/2 , y: pullUpView.frame.size.height/2 - (spinner?.frame.height)!/2)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
    }
    
    
    @IBAction func centerMapButtonTapped(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerToLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9597846866, green: 0.6503693461, blue: 0.1371207833, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
        
    }
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
        animatePullUpViewUp()
        addSwipeDown()
        addSpinner()
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

