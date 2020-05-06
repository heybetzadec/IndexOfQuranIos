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
    
    private var languageId = 1
    private var tranlationId = 154
    
    private var bottomItems =  Array<BottomItem>()
    
    
    override func viewDidAppear(_ animated: Bool) {
        let mainTabBar = self.tabBarController as! AppTabBarViewController
        if !mainTabBar.searchString.isEmpty {
//            print("mainTabBar.searchString = \(mainTabBar.searchString)")
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let searchViewController = storyBoard.instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
            searchViewController.tranlationId = self.tranlationId
            searchViewController.languageId = self.languageId
//            searchViewController.searchString = mainTabBar.searchString
//            mainTabBar.searchString = ""
            self.navigationController?.pushViewController(searchViewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        SwiftEventBus.onMainThread(self, name:"goToSearch") { result in
//            print("goToSearch")
//            let searchString : String = result?.object as! String
//            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
//            let searchViewController = storyBoard.instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
//            searchViewController.tranlationId = self.tranlationId
//            searchViewController.languageId = self.languageId
//            searchViewController.searchString = searchString
//            self.navigationController?.pushViewController(searchViewController, animated: true)
//        }
        
        
        bottomItems.append(BottomItem(id: 1, name: "Tam arama", icon: "magnifyingglass"))
        bottomItems.append(BottomItem(id: 2, name: "Pinlenmiş ayetler", icon: "pin"))
        bottomItems.append(BottomItem(id: 3, name: "Hatırlatıcı", icon: "checkmark.seal"))
        bottomItems.append(BottomItem(id: 3, name: "Ayarları", icon: "gear"))
        bottomItems.append(BottomItem(id: 4, name: "Kapat", icon: "exclamationmark.octagon"))
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
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
        return cell
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        switch indexPath.row {
        case 0:
            let searchViewController = storyBoard.instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
            searchViewController.tranlationId = tranlationId
            searchViewController.languageId = languageId
            searchViewController.searchString = ""
            navigationController?.pushViewController(searchViewController, animated: true)
        default:
            break
        }
    }
    
}
