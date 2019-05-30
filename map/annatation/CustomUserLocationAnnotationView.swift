//
//  CustomUserLocationAnnotationView.swift
//  map
//
//  Created by Ba Tuan on 5/12/19.
//  Copyright © 2019 Thái Tuân. All rights reserved.
//

import Foundation
import Mapbox
class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
    var border: CALayer!
    var dot: CALayer!
    let size = 5
    var color : UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        self.color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
        }
        if CLLocationCoordinate2DIsValid(self.userLocation!.coordinate) {
            setupDot()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    func setupDot() {
        if dot == nil || border == nil {
            border = CALayer()
            border.bounds = bounds
            border.cornerRadius = border.bounds.width / 2
            border.backgroundColor = color.cgColor
            border.opacity = 0.0
            dot = CALayer()
            dot.bounds = CGRect(x: 0, y: 0, width: size * 2 / 3, height: size * 2 / 3)
            dot.cornerRadius = dot.bounds.width / 2
            dot.backgroundColor = color.cgColor
            dot.opacity = 0.0
            layer.addSublayer(border)
            layer.addSublayer(dot)
        }
    }
}
