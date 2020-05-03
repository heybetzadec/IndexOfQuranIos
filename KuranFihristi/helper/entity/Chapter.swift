//
//  Chapter.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Chapter {
    
    var chapterId: Int = 0
    var chapterName: String = ""
    
    init() {

    }
    
    init(chapterId:Int, chapterName: String) {
        self.chapterId = chapterId
        self.chapterName = chapterName
    }
    
}
