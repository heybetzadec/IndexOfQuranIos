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
    var notRegisterSearch = true
//    var goToVerseBy = VerseBy()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SwiftEventBus.onMainThread(self, name:"goToSearch") { result in
            self.searchString = result?.object as! String
            self.selectedIndex = 4
        }
        
//        SwiftEventBus.onMainThread(self, name:"goToVerse") { result in
////            self.goToVerseBy = result?.object as! VerseBy
//            self.selectedIndex = 0
//        }
        
        SwiftEventBus.onMainThread(self, name:"darkMode") { result in
            let darkMode = result?.object as! Bool
            if darkMode {
                self.overrideUserInterfaceStyle = .dark
            } else {
                self.overrideUserInterfaceStyle = .light
            }
        }
        
    }
    


}
