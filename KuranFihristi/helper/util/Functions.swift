//
//  Functions.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/5/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation
import UIKit

class Functions {
    
    func getDefaultBottomItems() -> Array<BottomItem> {
        var bottomItems =  Array<BottomItem>()
        bottomItems.append(BottomItem(id: 1, name: "select_others".localized, icon: "hand.point.left"))
        bottomItems.append(BottomItem(id: 2, name: "pin_selected".localized, icon: "square.and.arrow.up"))
        bottomItems.append(BottomItem(id: 3, name: "copy_selected".localized, icon: "doc.on.doc"))
        bottomItems.append(BottomItem(id: 4, name: "pin_selected".localized, icon: "pin"))
        return bottomItems
    }
    
    func showToast(message : String, view: UIView) {
        let h = view.frame.size.height
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 75, y: h - h/2 , width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.superview?.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    
}
