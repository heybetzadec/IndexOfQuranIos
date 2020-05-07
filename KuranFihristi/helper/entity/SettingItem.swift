//
//  SettingItem.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/7/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class SettingItem {
    
    var id: Int = 0
    var name: String = ""
    var value: String = ""
    
    init() {

    }
    
    init(id:Int, name: String, value: String) {
        self.id = id
        self.name = name
        self.value = value
    }
    
}
