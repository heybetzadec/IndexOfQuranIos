//
//  ReminderViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/6/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus
import UserNotifications
import BackgroundTasks

class ReminderViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    private let dataBase = DataBase()
    private var reminders = Array<Reminder>()
    private var funcs = Functions()
    private var addReminderShow = false
    private var defaults = UserDefaults.standard
    var translationId = 154
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "ayat_reminder".localized

        reminders = dataBase.getReminders()
        
        SwiftEventBus.onMainThread(self, name:"addReminder") { result in
            let dt = result?.object as! String
            let dtArray = dt.split(separator: ":")
            let hour = Int(dtArray[0]) ?? 11
            let minute = Int(dtArray[1]) ?? 0
            let reminder = Reminder(hour: hour, minute: minute, isActive: 1)
            
            let checkReminders = self.reminders.filter { (Reminder) -> Bool in
                Reminder.hour == hour && Reminder.minute == minute
            }
            if checkReminders.count == 0 {
                self.reminders.removeAll { (Reminder) -> Bool in
                    Reminder.id == 0
                }
                self.reminders.insert(reminder, at: 0)
//                print("----> insert reminder: \(reminder.hour):\(reminder.minute)")
                self.dataBase.insertReminder(reminder: reminder)
                self.addReminderShow = false
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.funcs.showToast(message: "Already exist", view: self.view)
            }
            self.tableView.reloadData()
            
            
            self.scheduleBackgroundTaskScherluder(hour: hour, minute: minute)
            
        }
        
        SwiftEventBus.onMainThread(self, name:"cancelAddReminder") { result in
            self.reminders.removeAll { (Reminder) -> Bool in
                Reminder.id == 0
            }
            self.addReminderShow = false
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.tableView.reloadData()
        }
        
        
        SwiftEventBus.onMainThread(self, name:"timeSwitchChange") { result in
            let reminder = result?.object as! Reminder
            self.dataBase.updateReminder(reminder: reminder)
            
        }

        tableView.tableFooterView = UIView()
    }
    
    func scheduleBackgroundTaskScherluder (hour: Int, minute:Int) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let fetchTask = BGAppRefreshTaskRequest(identifier: "com.fihrist.heca.QuranFihristi.RandomAyat")
        fetchTask.earliestBeginDate = dateComponents.date //Date(timeIntervalSinceNow: 60)
        do {
          try BGTaskScheduler.shared.submit(fetchTask)
        } catch {
          print("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
    func scheduleNotifications(hour: Int, minute:Int) {
        let verseBy = dataBase.getRandomVerseBy(translationId: translationId)
        let content = UNMutableNotificationContent()
        let requestIdentifier = "fihristNotification\(hour)_\(minute)"

        content.title = "\(verseBy.chapterId). \(verseBy.chapterName), \(verseBy.verseId)"
        content.body = verseBy.verseText
        content.categoryIdentifier = "actionCategory"
        content.userInfo = ["chapterId": "\(verseBy.chapterId)", "verseId": "\(verseBy.verseId)"]
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in

            if error != nil {
                print(error?.localizedDescription ?? "some unknown error")
            }
            print("Notification Register Success")
        }
    }
    
    
//    func scheduleNotification(hour: Int, minute:Int) {
//        let verseBy = dataBase.getRandomVerseBy(translationId: translationId)
//
//
//
//        let center = UNUserNotificationCenter.current()
//        center.delegate = self
//        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
//        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
//        center.setNotificationCategories([category])
//
//        let content = UNMutableNotificationContent()
//        content.title = "\(verseBy.chapterId). \(verseBy.chapterName), \(verseBy.verseId)"
//        content.body = verseBy.verseText
////        content.categoryIdentifier = "alarm"
////        content.userInfo = ["customData": "fizzbuzz"]
//        content.sound = UNNotificationSound.default
////        content.badge = 1
//
//        var dateComponents = DateComponents()
//        dateComponents.hour = hour
//        dateComponents.minute = minute
////        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//
//        let request = UNNotificationRequest(identifier: "reminderayat", content: content, trigger: trigger)
//
//        center.add(request) { (error) in
//            print("notify error \(error.debugDescription)")
//        }
//
//
//    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = reminders[indexPath.row]
        
        if reminder.id == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addReminderViewCell", for: indexPath as IndexPath) as! AddReminderViewCell
            cell.timePicker.datePickerMode = .time
            cell.timePicker.timeZone = NSTimeZone.local
            cell.timePicker.locale = Locale(identifier: "en_GB")
            cell.timePicker.setDate(Date(), animated: false)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reminderViewCell", for: indexPath as IndexPath) as! ReminderViewCell
            var minStr = "\(reminder.minute)"
            if minStr.count == 1 {
                minStr = "0\(minStr)"
            }
            cell.reminder = reminder
            cell.timeLabel.text = "\(reminder.hour):\(minStr)"
            cell.timeSwitch.isOn = reminder.isActive == 1
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if addReminderShow && indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let reminder = reminders[indexPath.row]
            self.dataBase.deleteReminder(reminder: reminder)
            reminders.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    @IBAction func addButtonClick(_ sender: Any) {
        let res =  reminders.filter { (Reminder) -> Bool in
            Reminder.id == 0
        }
        
        if res.count == 0 {
            let r = Reminder(hour: 12, minute: 0, isActive: 1)
            r.id = 0
            reminders.insert(r, at: 0)
            addReminderShow = true
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            tableView.reloadData()
        }
    }
    
}
