//
//  ReminderViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/6/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class ReminderViewController: UITableViewController {
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    var reminders = Array<Reminder>()

    override func viewDidLoad() {
        super.viewDidLoad()

        reminders.append(Reminder(hour: 11, minute: 0, isActive: true))
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = reminders[indexPath.row]
        
        if reminder.id == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addReminderViewCell", for: indexPath as IndexPath) as! AddReminderViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reminderViewCell", for: indexPath as IndexPath) as! ReminderViewCell
            var minStr = "\(reminder.minute)"
            if minStr.count == 1 {
                minStr = "0\(minStr)"
            }
            cell.timeLabel.text = "\(reminder.hour):\(minStr)"
            cell.timeSwitch.isOn = reminder.isActive
            return cell
        }
        
        
    }
    
    
    @IBAction func addButtonClick(_ sender: Any) {
        let r = Reminder(hour: 12, minute: 0, isActive: true)
        r.id = 0
        reminders.insert(r, at: 0)
        tableView.reloadData()
    }
    
}
