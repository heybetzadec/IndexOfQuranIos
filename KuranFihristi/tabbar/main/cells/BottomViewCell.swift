//
//  BottomViewCell.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/3/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class BottomViewCell: UITableViewCell {
    
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var labelText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
