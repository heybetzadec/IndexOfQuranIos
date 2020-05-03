//
//  Name.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation


class Name {

    var nameId: Int = 0
    var nameText: String = ""
    var nameDescription: String = ""
    var nameHtml: String = ""
    
    init() {
        
    }
    
    init(nameId: Int, nameText: String, nameDescription: String) {
        self.nameId = nameId
        self.nameText = nameText
        self.nameDescription = nameDescription
    }
    
    
    init(nameId: Int, nameText: String, nameDescription: String, nameHtml:String) {
        self.nameId = nameId
        self.nameText = nameText
        self.nameDescription = nameDescription
        self.nameHtml = nameHtml
    }
    
}
