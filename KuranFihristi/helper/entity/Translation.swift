//
//  Translation.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Translation {
    
    var translationId: Int = 0
    var translationName: String = ""
    var languageId: Int = 0
    
    init() {

    }
    
    init(translationId:Int, translationName: String, languageId:Int) {
        self.translationId = translationId
        self.translationName = translationName
        self.languageId = languageId
    }
    
}
