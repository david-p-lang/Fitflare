//
//  ViewController.swift
//  FitFlare
//
//  Created by David Lang on 8/17/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //@IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let myButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
        myButton.imageView?.clipsToBounds = false
        myButton.imageView?.adjustsImageWhenAncestorFocused = true
        myButton.adjustsImageWhenHighlighted = true
        myButton.setImage(UIImage(named: "myImage"), for: UIControl.State.normal)
        self.view.addSubview(myButton)
//        myButton.topAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
//        myButton.heightAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        myButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        myButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
       // myButton.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        myButton.translatesAutoresizingMaskIntoConstraints = false
    }


}

