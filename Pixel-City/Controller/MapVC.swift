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
import Alamofire
import AlamofireImage
import SwiftyJSON

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var spinner:UIActivityIndicatorView?
    var progressLabel: UILabel?
    
    var photoCollectionFlowLayout = UICollectionViewFlowLayout()
    var photoCollection: UICollectionView?
    
    var locationManager = CLLocationManager()
    
    var authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius:Double = 1000
    
    var photoUrls = [String]()
    var photoArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        locationManager.delegate = self
        setupPhotoCollectionView()
        registerForPreviewing(with: self, sourceView: photoCollection!)
        configureLocationServices()
        centerToLocation()
        addDoubletap()
    
    }
    func setupPhotoCollectionView() {
        photoCollection = UICollectionView(frame: view.bounds, collectionViewLayout: photoCollectionFlowLayout)
        photoCollection?.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        photoCollection?.delegate = self
        photoCollection?.dataSource = self
        photoCollection?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pullUpView.addSubview(photoCollection!)
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
        cancelAllSessions()
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
        photoCollection?.addSubview(spinner!)
    }
    
    func addProgressLabel(){
        let labelWidth:CGFloat = 300
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: view.frame.size.width/2 - labelWidth/2, y: pullUpView.frame.size.height/2 + 25.0, width: labelWidth, height: 40)
        progressLabel?.font = UIFont(name: "Avenir-Book", size: 15)
        progressLabel?.text = ""
        progressLabel?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        progressLabel?.textAlignment = .center
        photoCollection?.addSubview(progressLabel!)
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func removeProgressLabel(){
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
    @IBAction func centerMapButtonTapped(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerToLocation()
        }
    }
    
    func retriveUrls(url: String, completion: @escaping CompletionHandler){
        Alamofire.request(url).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                guard let photos = json["photos"]["photo"].array else {return}
                for photo in photos {
                    let photoUrl = "https://farm\(photo["farm"].stringValue).staticflickr.com/\(photo["server"].stringValue)/\(photo["id"].stringValue)_\(photo["secret"].stringValue)_h.jpg"
                    self.photoUrls.append(photoUrl)
                }
                //print(self.photoUrls)
                completion(true)
            }else {
                debugPrint(response.result.error as Any)
                completion(false)
            }
        }
    }
    
    func retrivePhotos( completion: @escaping CompletionHandler) {
        for url in photoUrls {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                if response.result.error == nil {
                    guard let photo = response.result.value else {return}
                    self.photoArray.append(photo)
                    
                    self.progressLabel?.text = "Completed Loading \(self.photoArray.count)/\(self.photoUrls.count) Photos\n"
                    print("Completed Loading \(self.photoArray.count)/\(self.photoUrls.count) Photos\n\(self.photoUrls[self.photoArray.count-1])")
                    if self.photoArray.count == self.photoUrls.count {
                        completion(true)
                    }
                } else{
                    debugPrint(response.result.error as Any)
                    completion(false)
                }
            })
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionData, uploadData, downloadData) in
            sessionData.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
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
        removeSpinner()
        removeProgressLabel()
        cancelAllSessions()
        photoArray = []
        photoUrls = []
        photoCollection?.reloadData()
        
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
        let url = getApiUrl(apiKey: API_KEY, annotation: annotation, perPage: 40)
        self.retriveUrls(url: url) { (success) in
            if success{
                self.retrivePhotos(completion: { (success) in
                    if success {
                        print("retriving photos successful")
                        self.removeProgressLabel()
                        self.removeSpinner()
                        self.photoCollection?.reloadData()
                    }
                })
            }
        }
        animatePullUpViewUp()
        addSwipeDown()
        addSpinner()
        addProgressLabel()
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




extension MapVC:UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell {
            let imageView = UIImageView(image: photoArray[indexPath.row])
            cell.addSubview(imageView)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else{return}
        popVC.initData(image: photoArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
        
    }
    
    
}

extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = photoCollection?.indexPathForItem(at: location), let cell = photoCollection?.cellForItem(at: indexPath) else {return nil}
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else{return nil}
        popVC.initData(image: photoArray[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}

