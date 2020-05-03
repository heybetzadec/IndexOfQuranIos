//
//  VerseBy.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class VerseBy {
    
    var chapterId: Int = 0
    var chapterName: String = ""
    var verseId: Int = 0
    var verseText: String = ""
    
    init() {
        
    }
    
    init(chapterId:Int, chapterName: String, verseId: Int, verseText: String) {
        self.chapterId = chapterId
        self.chapterName = chapterName
        self.verseId = verseId
        self.verseText = verseText
    }
    
    
    
}
