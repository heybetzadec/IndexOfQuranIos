//
//  BottomItem.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/3/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation
import UIKit

class BottomItem {
    
    var id: Int = 0
    var name: String = ""
    var icon: String = "add"
    
    init() {

    }
    
    init(id:Int, name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
    
}
