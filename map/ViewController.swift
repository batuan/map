//
//  ViewController.swift
//  map
//
//  Created by Thái Tuân on 3/12/19.
//  Copyright © 2019 Thái Tuân. All rights reserved.
//

import UIKit
import Mapbox
import MapKit
import MapboxStatic
class ViewController: UIViewController, CLLocationManagerDelegate {
    lazy var mapView : MGLMapView = {
        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        let view1 = MGLMapView(frame: self.view.bounds, styleURL: url)
        view1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view1
    }()
    lazy var locationManager:CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        return manager
        //thai ba tuan 
    }()

    
    lazy var imageView: UIImageView = {
        let imagev = UIImageView()
        imagev.frame.size = self.view.frame.size
        return imagev
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        //mapView.setCenter(CLLocationCoordinate2DMake(21.0333, 105.8500), zoomLevel: 9, animated: false)
        
        view.addSubview(imageView)
        
        let camera = SnapshotCamera(lookingAtCenter: CLLocationCoordinate2DMake(21.0057,105.8445), zoomLevel: 16)
        let options = SnapshotOptions(styleURL: URL(string: "mapbox://styles/mapbox/streets-v11")!, camera: camera, size: CGSize(width: 800, height: 800))
        let snapshot = Snapshot(options: options, accessToken: "pk.eyJ1IjoidGhhaXR1YW4iLCJhIjoiY2pzbmgyMzMxMGM4bDQzcDFkdGRnNGN1YyJ9.A4ge-FCCpRgMsmTCvysilQ")
        imageView.image = snapshot.image!
    }
    var isLocated = false
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")

        if !isLocated {
            print("set location")
            mapView.setCenter(CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude), zoomLevel: 16, animated: true)
            isLocated = !isLocated
        }
    }


}

