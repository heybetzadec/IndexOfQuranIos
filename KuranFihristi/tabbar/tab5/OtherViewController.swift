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
        
        darkMode = defaults.bool(forKey: "darkMode")
        languageId = defaults.integer(forKey: "languageId")
        translationId = defaults.integer(forKey: "translationId")
        fontSize = defaults.integer(forKey: "fontSize")
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            if self.languageId != option.languageId {
                self.languageId = option.languageId
                self.navigationItem.title = "other".localized
                self.bottomItems.removeAll()
                self.bottomItems.append(BottomItem(id: 1, name: "quran_life".localized, icon: "book"))
                self.bottomItems.append(BottomItem(id: 2, name: "search_all".localized, icon: "magnifyingglass"))
                self.bottomItems.append(BottomItem(id: 3, name: "pinned_ayats".localized, icon: "pin"))
                self.bottomItems.append(BottomItem(id: 4, name: "ayat_reminder".localized, icon: "checkmark.seal"))
                self.bottomItems.append(BottomItem(id: 5, name: "settings".localized, icon: "gear"))
                self.bottomItems.append(BottomItem(id: 6, name: "close_app".localized, icon: "exclamationmark.octagon"))
                self.tableView.reloadData()
            }
            
            if self.fontSize != option.fontSize {
                self.fontSize = option.fontSize
                self.tableView.reloadData()
            }
            
            self.translationId = option.translationId
            
            self.darkMode = option.darkMode
        }
        
        
        bottomItems.append(BottomItem(id: 1, name: "search_all".localized, icon: "magnifyingglass"))
        bottomItems.append(BottomItem(id: 2, name: "pinned_ayats".localized, icon: "pin"))
        bottomItems.append(BottomItem(id: 3, name: "quran_life".localized, icon: "book"))
        bottomItems.append(BottomItem(id: 4, name: "ayat_reminder".localized, icon: "checkmark.seal"))
        bottomItems.append(BottomItem(id: 5, name: "settings".localized, icon: "gear"))
        bottomItems.append(BottomItem(id: 6, name: "close_app".localized, icon: "exclamationmark.octagon"))
        
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
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        switch indexPath.row {
        case 0:
            
            let searchViewController = storyBoard.instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
            searchViewController.translationId = translationId
            searchViewController.languageId = languageId
            searchViewController.searchString = ""
            searchViewController.darkMode = darkMode
            searchViewController.fontSize = fontSize
            navigationController?.pushViewController(searchViewController, animated: true)

        
        case 1:
            let pinViewController = storyBoard.instantiateViewController(withIdentifier: "pinViewController") as! PinViewController
            pinViewController.translationId = translationId
            pinViewController.languageId = languageId
            pinViewController.darkMode = darkMode
            pinViewController.fontSize = fontSize
            navigationController?.pushViewController(pinViewController, animated: true)
            

        case 2:
            
            let lifeViewController = storyBoard.instantiateViewController(withIdentifier: "lifeViewController") as! LifeViewController
            lifeViewController.translationId = translationId
            lifeViewController.languageId = languageId
            lifeViewController.fontSize = fontSize
            lifeViewController.darkMode = darkMode
            navigationController?.pushViewController(lifeViewController, animated: true)
            
        case 3:
            
            let reminderViewController = storyBoard.instantiateViewController(withIdentifier: "reminderViewController") as! ReminderViewController
            reminderViewController.translationId = translationId
            navigationController?.pushViewController(reminderViewController, animated: true)
        
        case 4:
            
            let settingViewController = storyBoard.instantiateViewController(withIdentifier: "settingViewController") as! SettingViewController
            navigationController?.pushViewController(settingViewController, animated: true)
            
        default:
            break
        }
    }
    
}
