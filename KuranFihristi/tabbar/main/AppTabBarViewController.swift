//
//  AppTabBarViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class AppTabBarViewController: UITabBarController{

    var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name:"goToSearch") { result in
            self.searchString = result?.object as! String
            self.selectedIndex = 4
        }
    }


}
