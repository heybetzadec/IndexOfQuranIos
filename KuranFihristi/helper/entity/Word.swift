//
//  Word.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Word {
    
    var wordId: Int = 0
    var wordName: String = ""
    
    init() {

    }
    
    init(wordId:Int, wordName: String) {
        self.wordId = wordId
        self.wordName = wordName
    }
    
}
