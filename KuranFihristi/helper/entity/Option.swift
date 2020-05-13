//
//  Option.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/9/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Option {
    
    var languageId = 1
    var translationId = 154
    var fontSize = 18
    var selectedOrder = 0
    var darkMode = false
    
    init() {
        
    }
    
    init(languageId:Int, translationId:Int, fontSize:Int, selectedOrder:Int, darkMode:Bool) {
        self.languageId = languageId
        self.translationId = translationId
        self.fontSize = fontSize
        self.selectedOrder = selectedOrder
        self.darkMode = darkMode
    }
    
}

