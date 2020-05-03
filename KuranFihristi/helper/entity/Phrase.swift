//
//  Phrase.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation


class Phrase {
    
    var phraseId: Int = 0
    var phraseName: String = ""
    
    init() {

    }
    
    init(phraseId:Int, phraseName: String) {
        self.phraseId = phraseId
        self.phraseName = phraseName
    }
    
}
