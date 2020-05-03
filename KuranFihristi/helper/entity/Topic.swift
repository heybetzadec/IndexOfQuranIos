//
//  Topic.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Topic {
    
    var topicId: Int = 0
    var topicName: String = ""
    
    init() {

    }
    
    init(topicId:Int, topicName: String) {
        self.topicId = topicId
        self.topicName = topicName
    }
    
}
