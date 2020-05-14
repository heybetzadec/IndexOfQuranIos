//
//  ReminderViewCell.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/6/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class ReminderViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSwitch: UISwitch!
    
    var reminder: Reminder = Reminder(hour: 0, minute: 0, isActive: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func timeSwitchChangeAction(_ sender: Any) {
        if timeSwitch.isOn {
            reminder.isActive = 1
        } else {
            reminder.isActive = 0
        }
        SwiftEventBus.post("addReminder", sender: reminder)
    }
    

}
