//
//  Letter.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Letter {
    
    var letterId: Int = 0
    var letterName: String = ""
    
    init() {

    }
    
    init(letterId:Int, letterName: String) {
        self.letterId = letterId
        self.letterName = letterName
    }
    
}
