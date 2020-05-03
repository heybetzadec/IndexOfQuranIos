//
//  Verse.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Verse {

    var chapterId: Int = 0
    var verseId: Int = 0
    var verseText: String = ""
    var isChecked: Bool = false
    
    init() {
        
    }
    
    init(chapterId: Int, verseId: Int, verseText: String) {
        self.chapterId = chapterId
        self.verseId = verseId
        self.verseText = verseText
    }
    
}
