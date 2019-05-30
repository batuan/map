//
//  CustomItemView.swift
//  map
//
//  Created by Ba Tuan on 5/12/19.
//  Copyright © 2019 Thái Tuân. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
class CustomItemView : UIView {
    var selectedFeature = MGLPointFeature()
    
    var mainController : ViewController!
    
    @IBOutlet weak var imageBuildingView: UIImageView!
    @IBOutlet var containerView: CustomItemView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemHourLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemPhoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    var iconImage = UIImage()
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    var routeDistance = ""
    var themeColor : Color!
    
    @IBOutlet weak var btnCall: UIButton!
    override init(frame: CGRect) {
        super.init(frame: CGRect())
        
        Bundle.main.loadNibNamed("CustomItemView", owner: self, options: nil)
        backgroundColor = .purple
        
        self.frame = bounds
        addSubview(containerView)
        
        containerView.frame = bounds
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        if containerView.headerView != nil {
            containerView.headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.headerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.headerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.25)
        }
        
        if containerView.iconImageView != nil {
            containerView.iconImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @objc func call() -> Void {
        guard let number_string = containerView.itemPhoneNumberLabel.text else {
            print("not have number")
            return
        }
        
        let number_phone = number_string.removingWhitespaces()
        print("number_phone: \(number_phone)")
        guard let number = URL(string: "tel://" + number_phone) else { return }
        UIApplication.shared.open(number)
        print("call")
    }
    
    required convenience init(feature: MGLPointFeature, themeColor: Color, iconImage: UIImage) {
        
        self.init(frame: CGRect())
        self.themeColor = themeColor
        self.iconImage = iconImage
        self.selectedFeature = feature
        
        createItemView()
        
        updateLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Update the attribute keys based on your data's format.
    public func updateLabels() {
        
        if let name : String = selectedFeature.attribute(forKey: "name") as? String {
            containerView.itemNameLabel.text = name
        }
        if let hours : String = selectedFeature.attribute(forKey: "hours") as? String {
            containerView.itemHourLabel.text = hours
        }
        if let description : String = selectedFeature.attribute(forKey: "description") as? String  {
            containerView.itemDescriptionLabel.text = description
        }
        
        if let number : String = selectedFeature.attribute(forKey: "phone") as? String  {
            containerView.itemPhoneNumberLabel.text = number
        }
        
        if let imageLink : String = selectedFeature.attribute(forKey: "image") as? String{
            print("imageLink is: \(imageLink)")
            self.containerView.iconImageView.downloaded(from: imageLink)
            
        }
        
        containerView.btnCall.addTarget(self, action: #selector(call), for: .touchUpInside)
        
        containerView.iconImageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(pushDetailControler)))
        
        
    }
    
    @objc func pushDetailControler() -> Void {
        print("debug::push detail Controller")
        print(self.window?.rootViewController)
        if let rootViewController = self.window!.rootViewController as? UINavigationController {
            print("debug::cast root view complete")
            let pushViewController = DetailViewController()
            //rootViewController.navigationBar.isHidden = false
            rootViewController.pushViewController(pushViewController, animated: true)
        }
    }
    
    func createItemView() {
        
        containerView.headerView.backgroundColor = themeColor.primaryDarkColor
        
        // Create the icon image for the logo.
        containerView.iconImageView.image = iconImage
        
        // Create item name label.
        containerView.itemNameLabel.textColor = .white
        
        // Create description label.
        containerView.itemDescriptionLabel.textColor = .white
        
        // Create hours open label.
        containerView.itemHourLabel.textColor = themeColor.lowerCardTextColor
        
        //Create phone number label.
        containerView.itemPhoneNumberLabel.textColor = themeColor.lowerCardTextColor
        
        // Static labels for attributes.
        containerView.hoursLabel.textColor = themeColor.lowerCardTextColor
        
        containerView.phoneNumberLabel.textColor = themeColor.lowerCardTextColor
    }
}


extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
