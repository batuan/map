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
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

class ViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {
    var viewControllerTheme : Theme = Theme(defaultMarker: UIImage(named: "blue_unselected_house")!,
                                            selectedMarker: UIImage(named: "blue_selected_house")!,
                                            styleURL: MGLStyle.streetsStyleURL,
                                            themeColor: ThemeColor.neutralTheme,
                                            fileURL: Bundle.main.url(forResource: "bach_khoa_ha_noi_buildings", withExtension: "geojson")!)
    var centerBachKhoa = CLLocationCoordinate2D(latitude: 21.00703, longitude: 105.84318)
    var userLocationSource : MGLShapeSource?
    var itemView : CustomItemView! // Keeps track of the current CustomItemView.
    var featuresWithRoute : [String : (MGLPointFeature, [CLLocationCoordinate2D])] = [:]
    let uniqueIdentifier = "name" // Replace this with the property key for a value that is unique within your data. Do not use coordinates.
    var selectedFeature : (MGLPointFeature, [CLLocationCoordinate2D])?
    //mark:: set variable for pushdetail controller
    var selectedBuildingFeature: MGLPointFeature?
    var imageLink : String?
    var buildingName: String?
    
    
    var pageViewController : UIPageViewController!
    let userLocationFeature = MGLPointFeature()
    var userLocationCoordinate = CLLocationCoordinate2D() // This can be removed if the user location is
    var building_features : [MGLPointFeature] = []
    var customItemViewSize = CGRect()
    lazy var mapView : MGLMapView = {
        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        let view1 = MGLMapView(frame: self.view.bounds, styleURL: url)
        view1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view1.userTrackingMode = .follow
        //view1.setCenter(CLLocationCoordinate2D(latitude: 21.0057, longitude: 105.8445), zoomLevel: 16, animated: true)
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
        imagev.frame.size = CGSize(width: 10, height: 10)
        imagev.image = UIImage(named: "d4_DHBKHN")
        imagev.backgroundColor = UIColor.white
        imagev.translatesAutoresizingMaskIntoConstraints = false
        return imagev
    }()
    
    @objc func pushImageController(_ sender: UITapGestureRecognizer) -> Void {
        let detail = DetailViewController()
        detail.userCoordinate = userLocationFeature.coordinate
        detail.feature = self.selectedBuildingFeature
        detail.buildingName = self.buildingName!
        detail.imageLink = self.imageLink!
        self.present(detail, animated: true) {
            print("debug::pushImageviewcontroller")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        mapView.setCenter(centerBachKhoa, zoomLevel: 16, animated: false)
        view.addSubview(mapView)
        mapView.delegate = self
        
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleItemTap(sender:))))
        
        customItemViewSize = CGRect(x: 0, y: mapView.bounds.height * 3 / 4, width: view.bounds.width, height: view.bounds.height / 4)
        
        addPageViewController()
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        DispatchQueue.global().async {
            let url = self.viewControllerTheme.fileURL  // Set the URL containing your store locations.
            
            let data = try! Data(contentsOf: url)
            DispatchQueue.main.async {
                self.drawPointData(data: data)
            }
        }
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            addUserLocationDot(to: style)
        } else {
            print("set center")
            
        }
    }
    
    func drawPointData(data: Data) {
        guard let style = mapView.style else { return }
        
        let feature = try! MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as! MGLShapeCollectionFeature
        
        let source = MGLShapeSource(identifier: "store-locations", shape: feature, options: nil)
        style.addSource(source)
        
        // Set the default item image.
        style.setImage((viewControllerTheme.defaultMarker), forName: "unselected_marker")
        // Set the image for the selected item.
        style.setImage((viewControllerTheme.selectedMarker), forName: "selected_marker")
        
        let symbolLayer = MGLSymbolStyleLayer(identifier: "store-locations", source: source)
        
        symbolLayer.iconImageName = NSExpression(forConstantValue: "unselected_marker")
        symbolLayer.iconAllowsOverlap = NSExpression(forConstantValue: 1)
        
        style.addLayer(symbolLayer)
        
        building_features = feature.shapes as! [MGLPointFeature]
        if CLLocationManager.authorizationStatus() != .authorizedAlways || CLLocationManager.authorizationStatus() != .authorizedWhenInUse  {
            populateFeaturesWithRoutes()//get routes to building
            
        }
    }
    
    func addUserLocationDot(to style: MGLStyle) {
        if !CLLocationCoordinate2DIsValid(userLocationFeature.coordinate) {
            userLocationFeature.coordinate = centerBachKhoa
        }
        
        userLocationSource = MGLShapeSource(identifier: "user-location", features: [userLocationFeature], options: nil)
        let userLocationStyle = MGLCircleStyleLayer(identifier: "user-location-style", source: userLocationSource!)
        // Set the color for the user location dot, if applicable.
        userLocationStyle.circleColor = NSExpression(forConstantValue: viewControllerTheme.themeColor.primaryDarkColor)
        userLocationStyle.circleRadius = NSExpression(forConstantValue: 7)
        userLocationStyle.circleStrokeColor = NSExpression(forConstantValue: viewControllerTheme.themeColor.primaryDarkColor)
        userLocationStyle.circleStrokeWidth = NSExpression(forConstantValue: 4)
        userLocationStyle.circleStrokeOpacity = NSExpression(forConstantValue: 0.5)
        
        style.addSource(userLocationSource!)
        style.addLayer(userLocationStyle)
    }
    
    
    @objc func handleItemTap(sender: UIGestureRecognizer) {
        print("debug::handleItemTap")
        if sender.state == .ended {
            
            let point = sender.location(in: sender.view!)
            let layer: Set = ["store-locations"]
            if mapView.visibleFeatures(at: point, styleLayerIdentifiers: layer).count > 0 && !(UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft) {
                
                // If there is an item at the tap's location, change the marker to the selected marker.
                for feature in mapView.visibleFeatures(at: point, styleLayerIdentifiers: layer)
                    where feature is MGLPointFeature {
                        changeItemColor(feature: feature)
                        generateItemPages(feature: feature as! MGLPointFeature)
                        
                        let mapViewSize = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 3/4)
                        mapView.frame = mapViewSize
                        pageViewController.view.isHidden = false
                        imageView.isHidden = false
                        let image = feature.attribute(forKey: "image") as? String
                        imageLink = image
                        buildingName = feature.attribute(forKey: "name") as? String
                        if imageLink != ""{
                            imageView.downloaded(from: image!)
                        }
                        
                }
            } else {
                // If there isn't an item at the tap's location, reset the map.
                changeItemColor(feature: MGLPointFeature())
                
                if let routeLineLayer = mapView.style?.layer(withIdentifier: "route-style") {
                    routeLineLayer.isVisible = false
                }
                
                pageViewController.view.isHidden = true
                imageView.isHidden = true
                mapView.frame = view.bounds
            }
        }
    }
    
    func changeItemColor(feature: MGLFeature) {
        print("debug:: changeItemcolor")
        let layer = mapView.style?.layer(withIdentifier: "store-locations") as! MGLSymbolStyleLayer
        if let name = feature.attribute(forKey: "name") as? String {
            
            // Change the icon to the selected icon based on the feature name. If multiple items have the same name, choose an attribute that is unique.
            layer.iconImageName = NSExpression(format: "TERNARY(name = %@, 'selected_marker', 'unselected_marker')", name)
            
        } else {
            // Deselect all items if no feature was selected.
            layer.iconImageName = NSExpression(forConstantValue: "unselected_marker")
        }
    }
    
    func getRoute(from origin: CLLocationCoordinate2D,
                  to destination: MGLPointFeature) -> [CLLocationCoordinate2D]{
        
        var routeCoordinates : [CLLocationCoordinate2D] = []
        let originWaypoint = Waypoint(coordinate: origin)
        let destinationWaypoint = Waypoint(coordinate: destination.coordinate)
        
        let options = RouteOptions(waypoints: [originWaypoint, destinationWaypoint], profileIdentifier: .automobileAvoidingTraffic)
        
        _ = Directions.shared.calculate(options) { (waypoints, routes, error) in
            
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                return
            }
            
            guard let route = routes?.first else { return }
            routeCoordinates = route.coordinates!
            self.featuresWithRoute[self.getKeyForFeature(feature: destination)] = (destination, routeCoordinates)
        }
        return routeCoordinates
    }
    
    
    //add pageview to mapview when tap features in map
    
    func addPageViewController() {
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.isDoubleSided = false
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.frame = customItemViewSize
        pageViewController.view.backgroundColor = viewControllerTheme.themeColor.primaryDarkColor
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(pageViewController.view)
        pageViewController.view.isHidden = true
        
        self.view.addSubview(imageView)
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushImageController(_:))))
        imageView.isUserInteractionEnabled = true

        imageView.bottomAnchor.constraint(equalTo: pageViewController.view.topAnchor, constant: -5).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        //imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.isHidden = true
    }
    
    // Determine the feature that was tapped on.
    func generateItemPages(feature: MGLPointFeature) {
        
        mapView.centerCoordinate = feature.coordinate
        selectedBuildingFeature = feature
        selectedFeature = featuresWithRoute[getKeyForFeature(feature: feature)]
        
        let themeColor = viewControllerTheme.themeColor
        let iconImage = viewControllerTheme.defaultMarker
        
        let vc = UIViewController()
        itemView = CustomItemView(feature: feature, themeColor: themeColor, iconImage: iconImage)
        itemView.frame = customItemViewSize
        if let selectedRoute = selectedFeature?.1 {
            print("debugforroute:: coordidate \(selectedFeature!.0.coordinate)")
            drawRouteLine(from: selectedRoute)
        }
        itemView.mainController = self
        vc.view = itemView
        vc.view.autoresizingMask =  [ .flexibleHeight, .flexibleWidth ]
        pageViewController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        
    }
    
    func populateFeaturesWithRoutes() {
        if CLLocationCoordinate2DIsValid(userLocationFeature.coordinate) {
            for point in building_features {
                let routeCoordinates = getRoute(from: userLocationFeature.coordinate, to: point)
                featuresWithRoute[getKeyForFeature(feature: point)] = (point, routeCoordinates)
            }
        }
    }

    
    func drawRouteLine(from route: [CLLocationCoordinate2D]) {
        
        print("debug::indrawRouteLine")
        if route.count > 0 {
            if let routeStyleLayer = self.mapView.style?.layer(withIdentifier: "route-style") {
                routeStyleLayer.isVisible = true
            }
            
            let polyline = MGLPolylineFeature(coordinates: route, count: UInt(route.count))
            
            if let source = self.mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
                source.shape = polyline
            } else {
                let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
                self.mapView.style?.addSource(source)
                
                let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
                
                // Set the line color to the theme's color.
                lineStyle.lineColor = NSExpression(forConstantValue: self.viewControllerTheme.themeColor.navigationLineColor)
                lineStyle.lineJoin = NSExpression(forConstantValue: "round")
                lineStyle.lineWidth = NSExpression(forConstantValue: 3)
                
                if let userDot = mapView.style?.layer(withIdentifier: "user-location-style") {
                    self.mapView.style?.insertLayer(lineStyle, below: userDot)
                } else {
                    for layer in (mapView.style?.layers.reversed())! where layer.isKind(of: MGLSymbolStyleLayer.self) {
                        self.mapView.style?.insertLayer(lineStyle, below: layer)
                        break
                    }
                }
            }
        }
    }

    // MARK: Functions to lookup features.
    // Get the key for a feature.
    func getKeyForFeature(feature: MGLPointFeature) -> String {
        if let selectFeature = feature.attribute(forKey: uniqueIdentifier) as? String {
            return selectFeature
        }
        return ""
    }
    
    // Get the index for a feature in the array of features.
    func getIndexForFeature(feature: MGLPointFeature) -> Int {
        // Filter the features based on a unique attribute. In this case, the location's phone number is used.
        let selectFeature = building_features.filter({ ($0.attribute(forKey: uniqueIdentifier) as! String) == (feature.attribute(forKey: uniqueIdentifier) as! String) })
        if let index = building_features.index(of: selectFeature.first!) {
            return index
        }
        return 0
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // second
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            let annot = CustomUserLocationAnnotationView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), color: (viewControllerTheme.themeColor.primaryDarkColor))
            
            return annot
        }
        return nil

    }
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if let coord = userLocation?.coordinate {
            userLocationFeature.coordinate = coord
            userLocationSource?.shape = userLocationFeature
            
            //mapView.setCenter(coord, animated: false)
            if CLLocationCoordinate2DIsValid(userLocationFeature.coordinate) {
                populateFeaturesWithRoutes()
            }
        }
    }
    
    
    @objc func OpenController() -> Void {
        print("touch custonview")
        self.navigationController?.pushViewController(InfomationViewController(), animated: true)
    }
    
    
   
    
}


// MARK: UIPageViewControllerDelegate and UIPageViewControllerDataSource methods.
extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let view = pendingViewControllers.first?.view as? CustomItemView {
            selectedFeature = featuresWithRoute[getKeyForFeature(feature: view.selectedFeature)]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("debug::in didFinishAnimating")
        if let view = pageViewController.viewControllers?.first?.view as? CustomItemView {
            if let currentFeature = featuresWithRoute[getKeyForFeature(feature: view.selectedFeature)] {
                selectedFeature = currentFeature
                mapView.centerCoordinate = (selectedFeature?.0.coordinate)!
                drawRouteLine(from: (selectedFeature?.1)!)
                changeItemColor(feature: (selectedFeature?.0)!)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("debugg: in viewControllerBefore")
        if let currentFeature = selectedFeature?.0 {
            let index = getIndexForFeature(feature: currentFeature)
            let nextVC = UIViewController()
            var nextFeature = MGLPointFeature()
            
            let themeColor = viewControllerTheme.themeColor
            let iconImage = viewControllerTheme.defaultMarker
            if index - 1 < 0 {
                nextFeature = building_features.last!
            } else {
                nextFeature = building_features[index-1]
            }
            nextVC.view = CustomItemView(feature: nextFeature, themeColor: themeColor, iconImage: iconImage)
            itemView = nextVC.view as! CustomItemView!
            return nextVC
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentFeature = selectedFeature?.0 {
            print("currentFeature: \(currentFeature.attributes)")
            print("debugg: in viewControllerAfter")
            let index = getIndexForFeature(feature: currentFeature)
            let nextVC = UIViewController()
            var nextFeature = MGLPointFeature()
            
            
            let themeColor = viewControllerTheme.themeColor
            let iconImage = viewControllerTheme.defaultMarker
            if index != (building_features.count - 1) {
                nextFeature = building_features[index+1]
            } else {
                nextFeature = building_features[0]
            }
            print(nextFeature)
            selectedFeature = featuresWithRoute[getKeyForFeature(feature: nextFeature)]
            nextVC.view = CustomItemView(feature: nextFeature, themeColor: themeColor, iconImage: iconImage)
            itemView = nextVC.view as! CustomItemView!
            
            return nextVC
            
        }
        return nil
    }
    
    
}


class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        
        layer.borderWidth = selected ? bounds.width / 4 : 2
        layer.add(animation, forKey: "borderWidth")
    }
}


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
