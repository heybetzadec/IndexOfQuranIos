//
//  SettingViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class SettingViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    private var languageId = 1
    private var translationId = 1
    private var fontSize = 18
    
    private let dataBase = DataBase()
    private var settingItem =  Array<SettingItem>()
    
    
//    private let datePicker: UIDatePicker = UIDatePicker()

    private let pickerView: UIPickerView = UIPickerView()
    private var defaults = UserDefaults.standard
    private var emptyGesture = UITapGestureRecognizer()
    private var pickerData = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    private var languageItems = Array<String>()
    private var translationItems = Array<String>()
    private var orderByItems = Array<String>()
    private var fontSizeItems = Array<String>()
    private var interfaceModeItems = Array<String>()
    
    
    private var selectedTableRow = 0
    
    private var selectedLanguage = 0
    private var selectedTranslation = 0
    private var selectedOrder = 0
    private var selectedFontSize = 4
    private var selectedInterfaceMode = 0
    
    
    private var languages = Array<Language>()
    private var translations = Array<Translation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "settings".localized
        
        languageId = defaults.integer(forKey: "languageId")
        translationId = defaults.integer(forKey: "translationId")
        
        selectedLanguage = defaults.integer(forKey: "selectedLanguage")
        selectedTranslation = defaults.integer(forKey: "selectedTranslation")
        selectedOrder = defaults.integer(forKey: "selectedOrder")
        selectedFontSize = defaults.integer(forKey: "selectedFontSize")
        selectedInterfaceMode = defaults.integer(forKey: "selectedInterfaceMode")
        
//        print("languageId -> \(languageId)")
//        print("translationId -> \(translationId)")
//        print("selectedLanguage -> \(selectedLanguage)")
//        print("selectedTranslation -> \(selectedTranslation)")
        
        languages = dataBase.getLanguages()
        languageItems.removeAll()
        for language in languages {
            languageItems.append(language.languageName)
        }
        
        translations = dataBase.getTranslations(languageId: languageId)
        translationItems.removeAll()
        for translate in translations {
            translationItems.append(translate.translationName)
        }
        orderByItems = ["by_sura".localized, "by_down".localized]
        fontSizeItems = ["14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]
        interfaceModeItems = ["system".localized, "light_mode".localized, "dark_mode".localized]
        
        settingItem.append(SettingItem(id: 1, name: "language".localized, value: languageItems[selectedLanguage]))
        settingItem.append(SettingItem(id: 2, name: "translation".localized, value: translationItems[selectedTranslation]))
        settingItem.append(SettingItem(id: 3, name: "alignment".localized, value: orderByItems[selectedOrder]))
        settingItem.append(SettingItem(id: 4, name: "font_size".localized, value: fontSizeItems[selectedFontSize]))
        settingItem.append(SettingItem(id: 5, name: "interface_mode".localized, value: interfaceModeItems[selectedInterfaceMode]))
        
        emptyGesture = UITapGestureRecognizer(target: self, action:  #selector(self.emptyClickAction))
        
        tableView.tableFooterView = UIView()
    }
    
    @objc func emptyClickAction(sender : UITapGestureRecognizer) {
        pickerView.removeFromSuperview()
        tableView.deselectRow(at: IndexPath(row: selectedTableRow, section: 0), animated: true)
    }
    
    
    func openPicker(data: Array<String>, selected: Int) {
        pickerData = data
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(selected, inComponent: 0, animated: false)
        let height = view.frame.height
        
        let emptyView = UIView()
        let tableHeight = tableView.contentSize.height
        emptyView.frame = CGRect(x: 0, y: tableHeight, width: view.frame.width, height: view.frame.height / 2 - tableHeight)
        emptyView.backgroundColor = .systemBackground
        view.addSubview(emptyView)
        emptyView.addGestureRecognizer(emptyGesture)
            
        pickerView.frame = CGRect(x: 0, y: height / 2 , width: view.frame.width, height: height / 3)
        pickerView.backgroundColor = UIColor.systemFill
        view.addSubview(pickerView)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch  selectedTableRow {
        case 0:
            selectedLanguage = row
            settingItem[0].value = languageItems[row]
            let language = languages[row]
            translations = dataBase.getTranslations(languageId: language.languageId)
            translationItems.removeAll()
            for translate in translations {
                translationItems.append(translate.translationName)
            }
            selectedTranslation = 0
            settingItem[1].value = translationItems[selectedTranslation]
            languageId = language.languageId
            translationId = translations[0].translationId
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            defaults.set(selectedLanguage, forKey: "selectedLanguage")
            defaults.set(selectedTranslation, forKey: "selectedTranslation")
            defaults.set(languageId, forKey: "languageId")
            defaults.set(translationId, forKey: "translationId")
            defaults.set(language.languageCode, forKey: "i18n_language")
            

            tabBarController?.viewControllers?[0].tabBarItem.title = "chapters".localized
            tabBarController?.viewControllers?[1].tabBarItem.title = "letters".localized
            tabBarController?.viewControllers?[2].tabBarItem.title = "topics".localized
            tabBarController?.viewControllers?[3].tabBarItem.title = "names".localized
            tabBarController?.viewControllers?[4].tabBarItem.title = "other".localized
            tabBarItem.title = "settings".localized
            

            orderByItems = ["by_sura".localized, "by_down".localized]
            interfaceModeItems = ["system".localized, "light_mode".localized, "dark_mode".localized]
            
            settingItem[0].name = "language".localized
            settingItem[1].name = "translation".localized
            settingItem[2].name = "alignment".localized
            settingItem[2].value = orderByItems[selectedOrder]
            settingItem[3].name = "font_size".localized
            settingItem[4].name = "interface_mode".localized
            settingItem[4].value = interfaceModeItems[selectedInterfaceMode]
            
            navigationItem.title = "settings".localized
            
            tableView.reloadData()
            
        case 1:
            selectedTranslation = row
            settingItem[1].value = translationItems[row]
            translationId = translations[selectedTranslation].translationId
            
            defaults.set(selectedTranslation, forKey: "selectedTranslation")
            defaults.set(translationId, forKey: "translationId")
        case 2:
            selectedOrder = row
            settingItem[2].value = orderByItems[row]
            defaults.set(selectedOrder, forKey: "selectedOrder")
        case 3:
            selectedFontSize = row
            settingItem[3].value = fontSizeItems[row]
            fontSize = Int(fontSizeItems[row]) ?? 18
            defaults.set(selectedFontSize, forKey: "selectedFontSize")
            defaults.set(fontSize, forKey: "fontSize")
            tableView.reloadData()
        case 4:
            selectedInterfaceMode = row
            settingItem[4].value = interfaceModeItems[row]
            
            var darkMode = false
            
            switch selectedInterfaceMode {
            case 0:
                switch traitCollection.userInterfaceStyle {
                    case .light, .unspecified:
                        darkMode = false
                    case .dark:
                        darkMode = true
                @unknown default:
                    darkMode = false
                }
            case 1:
                darkMode = false
            case 2:
                darkMode = true
            default:
                darkMode = false
            }
            
            SwiftEventBus.post("darkMode", sender: darkMode)
            defaults.set(darkMode, forKey: "darkMode")
            defaults.set(selectedInterfaceMode, forKey: "selectedInterfaceMode")
            
        default:
            break;
        }
        
        if selectedTableRow != 4 {
            SwiftEventBus.post("optionChange", sender: Option(languageId: languageId, translationId: translationId, fontSize: fontSize, selectedOrder: selectedOrder))
        }
        
        tableView.reloadRows(at: [IndexPath(row: selectedTableRow, section: 0)], with: .none)
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTableRow = indexPath.row
        switch  selectedTableRow {
        case 0:
            openPicker(data: languageItems, selected: selectedLanguage)
        case 1:
            openPicker(data: translationItems, selected: selectedTranslation)
        case 2:
            openPicker(data: orderByItems, selected: selectedOrder)
        case 3:
            openPicker(data: fontSizeItems, selected: selectedFontSize)
        case 4:
            openPicker(data: interfaceModeItems, selected: selectedInterfaceMode)
        default:
            break;
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItem.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingViewCell", for: indexPath as IndexPath) as! SettingViewCell
        let item = settingItem[indexPath.row]
        cell.nameLabel.text = item.name
        cell.valueLabel.text = item.value
        cell.nameLabel.font = .systemFont(ofSize: CGFloat(fontSize))
        cell.valueLabel.font = .systemFont(ofSize: CGFloat(fontSize))
        return cell
    }
    
}



extension String {
    var localized: String {
        if let _ = UserDefaults.standard.string(forKey: "i18n_language") {} else {
            // we set a default, just in case
            UserDefaults.standard.set("Base", forKey: "i18n_language")
            UserDefaults.standard.synchronize()
        }
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj") else {
            return self
        }
        guard let bundle = Bundle(path: path) else {
            return self
        }
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
