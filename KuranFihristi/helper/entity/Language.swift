//
//  Language.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Language {
    
    var languageId: Int = 0
    var languageName: String = ""
    var languageCode: String = ""
    
    init() {

    }
    
    init(languageId:Int, languageName: String, languageCode:String) {
        self.languageId = languageId
        self.languageName = languageName
        self.languageCode = languageCode
    }
    
}
