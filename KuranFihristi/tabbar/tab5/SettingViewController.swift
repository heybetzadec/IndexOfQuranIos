//
//  SettingViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    private let dataBase = DataBase()
    private var settingItem =  Array<SettingItem>()
    
    private let pickerView: UIPickerView = UIPickerView()
    private let datePicker: UIDatePicker = UIDatePicker()
    
    var pickerDataSource = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        settingItem.append(SettingItem(id: 1, name: "Dil", value: ""))
        settingItem.append(SettingItem(id: 2, name: "Meal", value: ""))
        settingItem.append(SettingItem(id: 3, name: "Sıralama", value: ""))
        settingItem.append(SettingItem(id: 4, name: "Yazı boyutu", value: ""))
        settingItem.append(SettingItem(id: 5, name: "Arayüz modu", value: ""))
        
        
        //                self.setupPicker()
        //                self.setupTimePicker()
        
        tableView.tableFooterView = UIView()
    }
    
    
    func setupPicker() {
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let height = view.frame.height
        pickerView.frame = CGRect(x: 0, y: height - height / 2, width: view.frame.width, height: height / 3)
        pickerView.backgroundColor = UIColor.systemFill
        view.addSubview(pickerView)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func setupTimePicker(){
        let height = view.frame.height
        datePicker.datePickerMode = .time
        datePicker.frame = CGRect(x: 0, y: height - height / 2, width: view.frame.width, height: height / 3)
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale(identifier: "en_GB")
        
        datePicker.backgroundColor = UIColor.systemFill
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        
        self.view.addSubview(datePicker)
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm"
        
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        print("Selected value \(selectedDate)")
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItem.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingViewCell", for: indexPath as IndexPath) as! SettingViewCell
        let item = settingItem[indexPath.row]
        cell.nameLabel.text = item.name
        cell.valueLabel.text = item.value
        return cell
    }
    
}
