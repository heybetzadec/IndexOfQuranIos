//
//  ItemViewCell.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/5/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class ItemViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
