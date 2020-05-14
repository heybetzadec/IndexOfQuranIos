//
//  OtherViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class OtherViewController: UITableViewController {
    
    private var fontSize = 17
    private var languageId = 1
    private var translationId = 154
    private var darkMode = false
    private var searchString = ""
    
    private var bottomItems =  Array<BottomItem>()
    private var defaults = UserDefaults.standard
    
    private var registerGoToSearch = false
    
    override func viewDidAppear(_ animated: Bool) {
        let mainTabBar = self.tabBarController as! AppTabBarViewController
        if !mainTabBar.searchString.isEmpty && mainTabBar.notRegisterSearch {
            mainTabBar.notRegisterSearch = false
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let searchViewController = storyBoard.instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
            searchViewController.searchString = mainTabBar.searchString
            searchViewController.translationId = self.translationId
            searchViewController.languageId = self.languageId
            searchViewController.searchString = mainTabBar.searchString
            self.navigationController?.pushViewController(searchViewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        darkMode = defaults.bool(forKey: "darkMode")
        languageId = defaults.integer(forKey: "languageId")
        translationId = defaults.integer(forKey: "translationId")
        fontSize = defaults.integer(forKey: "fontSize")
        
        
        SwiftEventBus.onMainThread(self, name:"goToSearch") { result in
            self.searchString = result?.object as! String
            self.navigationController?.popToRootViewController(animated: false)
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            
            let searchViewController = storyBoard.instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
            searchViewController.translationId = self.translationId
            searchViewController.languageId = self.languageId
            searchViewController.searchString = self.searchString
            _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                self.navigationController?.pushViewController(searchViewController, animated: true)
            }
        }
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            if self.languageId != option.languageId {
                self.languageId = option.languageId
                self.navigationItem.title = "other".localized
                self.bottomItems.removeAll()
                self.bottomItems = self.getBottomItems()
                self.tableView.reloadData()
            }
            
            if self.fontSize != option.fontSize {
                self.fontSize = option.fontSize
                self.tableView.reloadData()
            }
            
            self.translationId = option.translationId
            
            self.darkMode = option.darkMode
        }
        
        bottomItems = getBottomItems()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "other".localized
        
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bottomItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = bottomItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "otherViewCell", for: indexPath as IndexPath) as! OtherViewCell
        cell.itemIcon.image = UIImage(systemName: item.icon) ?? .add
        cell.itemLabel.text = item.name
        cell.itemLabel.font = .systemFont(ofSize: CGFloat(fontSize))
        return cell
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if bottomItems.count == 5 {
            switch indexPath.row {
            case 0:
                self.openSearchAll()
            case 1:
                self.openPinned()
            case 2:
                self.openLife()
            case 3:
                self.openSetting()
            case 4:
                exit(0)
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                self.openSearchAll()
            case 1:
                self.openPinned()
            case 2:
                self.openSetting()
            case 3:
                exit(0)
            default:
                break
            }
        }
        
    }
    
    private func getBottomItems() -> Array<BottomItem>{
        var items =  Array<BottomItem>()
        items.append(BottomItem(id: 1, name: "search_all".localized, icon: "magnifyingglass"))
        items.append(BottomItem(id: 2, name: "pinned_ayats".localized, icon: "pin"))
        if languageId != 3 {
            items.append(BottomItem(id: 3, name: "quran_life".localized, icon: "book"))
        }
//        items.append(BottomItem(id: 4, name: "ayat_reminder".localized, icon: "checkmark.seal"))
        items.append(BottomItem(id: 5, name: "settings".localized, icon: "gear"))
        items.append(BottomItem(id: 6, name: "close_app".localized, icon: "exclamationmark.octagon"))
        
        return items
    }
    
    private func openSearchAll(){
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let searchViewController = storyBoard.instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
        searchViewController.translationId = translationId
        searchViewController.languageId = languageId
        searchViewController.searchString = ""
        searchViewController.darkMode = darkMode
        searchViewController.fontSize = fontSize
        navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    private func openPinned(){
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let pinViewController = storyBoard.instantiateViewController(withIdentifier: "pinViewController") as! PinViewController
        pinViewController.translationId = translationId
        pinViewController.languageId = languageId
        pinViewController.darkMode = darkMode
        pinViewController.fontSize = fontSize
        navigationController?.pushViewController(pinViewController, animated: true)
    }
    
    private func openLife(){
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let lifeViewController = storyBoard.instantiateViewController(withIdentifier: "lifeViewController") as! LifeViewController
        lifeViewController.translationId = translationId
        lifeViewController.languageId = languageId
        lifeViewController.fontSize = fontSize
        lifeViewController.darkMode = darkMode
        navigationController?.pushViewController(lifeViewController, animated: true)
    }
    
    private func openReminder(){
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let reminderViewController = storyBoard.instantiateViewController(withIdentifier: "reminderViewController") as! ReminderViewController
        reminderViewController.translationId = translationId
        navigationController?.pushViewController(reminderViewController, animated: true)
    }
    
    private func openSetting(){
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let settingViewController = storyBoard.instantiateViewController(withIdentifier: "settingViewController") as! SettingViewController
        navigationController?.pushViewController(settingViewController, animated: true)
    }
}
