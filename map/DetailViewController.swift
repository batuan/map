//
//  DetailViewController.swift
//  map
//
//  Created by Ba Tuan on 5/14/19.
//  Copyright © 2019 Thái Tuân. All rights reserved.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
class DetailViewController: UIViewController, UIScrollViewDelegate {

    
    var buildingName : String?
    var feature: MGLPointFeature? 
    var imageLink: String?
    var descriptionBuild: String?
    var nameBuilding: String?
    var userCoordinate : CLLocationCoordinate2D?
    @IBAction func CloseViewController(_ sender: Any) {
        self.dismiss(animated: true) {
            print("debug::Dismis complete")
        }
    }
    
    var scrollView: UIScrollView?
    
    func creatreSlice() -> [UIView] {
        let view1 : infomationView  = Bundle.main.loadNibNamed("infomationView", owner: self, options: nil)?.first as! infomationView
        view1.aboutLabel.text = "ABout dai hoc bach khoa ha noi"
        let view2 : infomationView  = Bundle.main.loadNibNamed("infomationView", owner: self, options: nil)?.first as! infomationView
        view2.aboutLabel.text = "ABout dai hoc "
        return[view1, view2]
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var mScrollView: UIScrollView!
    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var imageOfBuilding: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let view1 : infomationView  = Bundle.main.loadNibNamed("infomationView", owner: self, options: nil)?.first as! infomationView
        view1.frame.size = CGSize(width: self.mScrollView!.frame.width, height: (self.mScrollView?.frame.height)!)
        view1.aboutLabel.text = "ABOUT " + (feature?.attribute(forKey: "name") as! String)
        var description = feature?.attribute(forKey: "description") as! String
        description.append(contentsOf: "\nOpen Time: \(feature?.attribute(forKey: "hours") as! String)")
        description.append(contentsOf: "\nPhone number: \(feature?.attribute(forKey: "phone") as! String)")
        view1.descriptionTextView.text = description
        view1.descriptionTextView.isEditable = false
        
        let image = feature?.attribute(forKey: "image") as! String
        if image != ""{
            self.imageOfBuilding.downloaded(from: image)
        }
        
        view1.btnNavigate.addTarget(self, action: #selector(naviagate), for: .touchUpInside)
        
        mScrollView.isPagingEnabled = true
        mScrollView.addSubview(view1)
        mScrollView.delegate = self
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        scrollView?.bringSubviewToFront(pageControl)
        imageOfBuilding.clipsToBounds = false
        self.view.backgroundColor = UIColor.white
        imageOfBuilding.contentMode = .scaleAspectFill

       // imageOfBuilding.downloaded(from: imageLink!)
        
    }
    
    func navigationService(route: Route) -> NavigationService {
        let mode: SimulationMode = .onPoorGPS
        return MapboxNavigationService(route: route, directions: Settings.directions, simulating: mode)
    }
    
    @objc func naviagate() -> Void {
        
        let options = NavigationRouteOptions(coordinates: [userCoordinate!, (feature?.coordinate)!])
        let direction = Directions(accessToken: "pk.eyJ1IjoidGFpMTQwNSIsImEiOiJjanZweDl0bmcxeHFqNDhxam05OGdqeHVyIn0.JOKCl1TMAk93XQItgccttw")
        direction.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
            let navigationService = self.navigationService(route: route)
            let navigationOptions = NavigationOptions(navigationService: navigationService)
            let navigationViewController = NavigationViewController(for: route, options: navigationOptions)
            self.present(navigationViewController, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

struct Settings {
    
    static var directions: NavigationDirections = NavigationDirections()
    
    static var selectedOfflineVersion: String? = nil
    
}
