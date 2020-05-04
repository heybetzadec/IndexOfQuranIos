//
//  Functions.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/5/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation

class Functions {
    
    func getDefaultBottomItems() -> Array<BottomItem> {
        var bottomItems =  Array<BottomItem>()
        bottomItems.append(BottomItem(id: 1, name: "Başkalarını seçin", icon: "hand.point.left"))
        bottomItems.append(BottomItem(id: 2, name: "Seçilenleri Paylaş", icon: "square.and.arrow.up"))
        bottomItems.append(BottomItem(id: 3, name: "Seçilenleri Kopyala", icon: "doc.on.doc"))
        bottomItems.append(BottomItem(id: 4, name: "Seçilenleri Pinle", icon: "pin"))
        return bottomItems
    }
}
