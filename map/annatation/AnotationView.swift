//
//  AnotationView.swift
//  map
//
//  Created by Ba Tuan on 5/15/19.
//  Copyright © 2019 Thái Tuân. All rights reserved.
//

import UIKit
import Mapbox

class AnotationView: UIView {
    var selectedFeature = MGLPointFeature()
    
    @IBOutlet weak var metterLabel: UILabel!
    @IBOutlet weak var descriptionLable: UILabel!
    @IBOutlet weak var imageBuilding: UIImageView!
    @IBOutlet weak var nameBuildinLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
