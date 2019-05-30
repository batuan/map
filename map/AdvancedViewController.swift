//
//  AdvancedViewController.swift
//  map
//
//  Created by Ba Tuan on 5/7/19.
//  Copyright © 2019 Thái Tuân. All rights reserved.
//

import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Mapbox

class AdvancedViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, NavigationMapViewDelegate, NavigationViewControllerDelegate {
    var mapView: NavigationMapView?
    var currentRoute: Route? {
        get {
            return routes?.first
        }
        set {
            guard let selected = newValue else { routes?.remove(at: 0); return }
            guard let routes = routes else { self.routes = [selected]; return }
            self.routes = [selected] + routes.filter { $0 != selected }
        }
    }
    var routes: [Route]? {
        didSet {
            guard let routes = routes, let current = routes.first else { mapView?.removeRoutes(); return }
            mapView?.showRoutes(routes)
            mapView?.showWaypoints(current)
        }
    }
    var allPoint = [MGLPointFeature]()
    var startButton: UIButton?
    var locationManager = CLLocationManager()
    
    private typealias RouteRequestSuccess = (([Route]) -> Void)
    private typealias RouteRequestFailure = ((NSError) -> Void)
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGeoJson()
        print("on advancedview")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView = NavigationMapView(frame: view.bounds)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView?.userTrackingMode = .follow
        mapView?.delegate = self
        mapView?.navigationMapDelegate = self
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView?.addGestureRecognizer(gesture)
        
        view.addSubview(mapView!)
        
        startButton = UIButton()
        startButton?.setTitle("Start Navigation", for: .normal)
        startButton?.translatesAutoresizingMaskIntoConstraints = false
        startButton?.backgroundColor = .blue
        startButton?.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        startButton?.addTarget(self, action: #selector(tappedButton(sender:)), for: .touchUpInside)
        startButton?.isHidden = true
        view.addSubview(startButton!)
        startButton?.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        startButton?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        view.setNeedsLayout()
    }
    
    //overriding layout lifecycle callback so we can style the start button
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton?.layer.cornerRadius = startButton!.bounds.midY
        startButton?.clipsToBounds = true
        startButton?.setNeedsDisplay()
        
    }
    
    
    @objc func tappedButton(sender: UIButton) {
        guard let route = currentRoute else { return }
        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
        let navigationService = MapboxNavigationService(route: route)
        navigationService.simulationMode = .always
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: route, options: navigationOptions)
        navigationViewController.delegate = self
        
        present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if (gesture.state == UIGestureRecognizer.State.ended) {
            print("Long press Ended");
        } else if (gesture.state == UIGestureRecognizer.State.began) {
            print("Long press detected.");
        }
        guard gesture.state == .ended else { return }
        
        let spot = gesture.location(in: mapView)
        print(spot.x)
        guard let location = mapView?.convert(spot, toCoordinateFrom: mapView) else { return }
        
        requestRoute(destination: location)
    }
    let direction = Directions(accessToken: "pk.eyJ1IjoidGhhaXR1YW4iLCJhIjoiY2pzbmgyMzMxMGM4bDQzcDFkdGRnNGN1YyJ9.A4ge-FCCpRgMsmTCvysilQ")
    func requestRoute(destination: CLLocationCoordinate2D) {
        guard let userLocation = mapView?.userLocation!.location else { return }
        let userWaypoint = Waypoint(location: userLocation, heading: mapView?.userLocation?.heading, name: "user")
        let destinationWaypoint = Waypoint(coordinate: destination)
        
        let options = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])
        print("on request Route")
        
        self.direction.calculate(options) { (waypoints, routes, error) in
            guard let routes = routes else { return }
            self.routes = routes
            self.startButton?.isHidden = false
            self.mapView?.showRoutes(routes)
            self.mapView?.showWaypoints(self.currentRoute!)
            
        }
    }
    
    // Delegate method called when the user selects a route
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        self.currentRoute = route
    }
    
    //load data from jsonfile
    func loadGeoJson() {
        DispatchQueue.global().async {
            // Get the path for example.geojson in the app’s bundle.
            guard let jsonUrl = Bundle.main.url(forResource: "bach_khoa_ha_noi", withExtension: "geojson") else {
                preconditionFailure("Failed to load local GeoJSON file")
            }
            
            guard let jsonData = try? Data(contentsOf: jsonUrl) else {
                preconditionFailure("Failed to parse GeoJSON file")
            }
            
            DispatchQueue.main.async {
                self.drawPolyline(geoJson: jsonData)
            }
        }
    }
    
    func drawPolyline(geoJson: Data) {
        // Add our GeoJSON data to the map as an MGLGeoJSONSource.
        // We can then reference this data from an MGLStyleLayer.
        
        // MGLMapView.style is optional, so you must guard against it not being set.
        
        guard let shapeCollectionFeature = try? MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue) as? MGLShapeCollectionFeature else {
            fatalError("Could not cast to specified MGLShapeCollectionFeature")
        }
        var i = 0
        for shape in (shapeCollectionFeature?.shapes)!{
            guard let Point = shape as? MGLPointFeature else{
                print("cant cast to Point Feature")
                return
            }
            print("coordinate: \(Point.coordinate) count: \(i)")
            allPoint.append(Point)
            i += 1
        }
        
        // Create new layer for the line.
        
    }
}
