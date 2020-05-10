//
//  LetterWord.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/10/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class LetterWord {
    
    var letter = Letter()
    var word = Word()
    
    init() {

    }
    
    init(letter:Letter, word: Word) {
        self.letter = letter
        self.word = word
    }
    
}
