//
//  TableViewHelper.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/14/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import Foundation
import UIKit

class TableViewHelper {

    class func EmptyMessage(message:String, viewController:UITableViewController) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.label
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        viewController.tableView.backgroundView = messageLabel;
        viewController.tableView.separatorStyle = .none;
    }
}
