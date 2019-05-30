//
//  InfomationViewController.swift
//  map
//
//  Created by Thái Tuân on 5/3/19.
//  Copyright © 2019 Thái Tuân. All rights reserved.
//

import UIKit

class InfomationViewController: UIViewController {
    var imageOfLocation: UIImageView!
    var descriptionOfLocation: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpUiView()
        // Do any additional setup after loading the view.
    }
    
    func SetUpUiView() -> Void {
        self.view.addSubview(imageOfLocation)
        self.view.addSubview(descriptionOfLocation)
        imageOfLocation.center = view.center
        imageOfLocation.frame.size = CGSize(width: self.view.frame.width, height: 500)
        imageOfLocation.backgroundColor = UIColor.gray
        descriptionOfLocation.frame.size = CGSize(width: self.view.frame.width, height: 200)
        descriptionOfLocation.translatesAutoresizingMaskIntoConstraints = false
        descriptionOfLocation.topAnchor.constraint(equalTo: imageOfLocation.bottomAnchor, constant: 10).isActive = true
        descriptionOfLocation.text = "Ba Tuan, Ngoc Thang, Van Tai"
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
