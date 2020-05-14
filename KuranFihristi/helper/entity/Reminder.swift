//
//  Reminder.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/10/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Reminder {
    
    var id = 1
    var hour = 0
    var minute = 0
    var isActive = 1
    
    init() {

    }
    
    init(hour:Int, minute: Int, isActive: Int) {
        self.hour = hour
        self.minute = minute
        self.isActive = isActive
    }
    
}
