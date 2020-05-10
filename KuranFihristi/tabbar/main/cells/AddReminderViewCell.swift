//
//  AddReminderViewCell.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/10/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class AddReminderViewCell: UITableViewCell {
    
    @IBOutlet weak var timePicker: UIDatePicker!
//    @IBOutlet weak var addButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func addButtonAction(_ sender: Any) {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let selectedDate: String = dateFormatter.string(from: timePicker.date)
        SwiftEventBus.post("addReminder", sender: selectedDate)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        SwiftEventBus.post("cancelAddReminder", sender: "cancel")
    }
}
