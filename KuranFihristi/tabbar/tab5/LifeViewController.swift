//
//  LifeViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/11/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class LifeViewController: UITableViewController , UISearchResultsUpdating, UISearchBarDelegate {
    
    private let dataBase = DataBase()
    private var lifes = Array<Life>()
    private var fullLifes = Array<Life>()
    private var searchController = UISearchController()
    private var defaults = UserDefaults.standard
    private var searchString = ""
    
    var languageId = 1
    var translationId = 154
    var fontSize = 17
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        languageId = defaults.integer(forKey: "languageId")
        translationId = defaults.integer(forKey: "translationId")
        fontSize = defaults.integer(forKey: "fontSize")
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            self.translationId = option.translationId
            
            if option.languageId != self.languageId {
                self.languageId = option.languageId
                self.fullLifes = self.dataBase.getLifes(languageId: self.languageId)
                self.lifes = self.fullLifes
                self.navigationItem.title = "quran_life".localized
                self.tableView.reloadData()
            }
            
            if self.fontSize != option.fontSize {
                self.fontSize = option.fontSize
                self.tableView.reloadData()
            }
        }
        
        if let button = self.navigationItem.rightBarButtonItem {
            button.isEnabled = false
            button.tintColor = UIColor.clear
        }
        
        fullLifes = dataBase.getLifes(languageId: languageId)
        lifes = fullLifes
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "quran_life".localized
        
        prepareSearchController()
        tableView.tableFooterView = UIView()
    }
    
    
    func prepareSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filter(searchText: "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filter(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        filter(searchText: searchText)
    }
    
    func filter(searchText:String){
        self.searchString = searchText
        if !searchText.isEmpty {
            let loverSearch = searchText.lowercased()
            let textAz = loverSearch.replacingOccurrences(ofes: ["e","i"], withes: ["ə", "i̇"])
            lifes = fullLifes.filter { (Life) -> Bool in
                let itemText = Life.lifeName.lowercased()
                return itemText.contains(loverSearch) || itemText.contains(textAz)
            }
            
            if searchText.count > 2 {
                lifes.insert(Life(lifeId: 0, lifeName: ""),  at: 0)
            }
        } else {
            lifes = fullLifes
        }
        tableView.reloadData()
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        searchController.searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lifes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lifeItem = lifes[indexPath.row]
        if lifeItem.lifeId == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "lifeItemViewCell", for: indexPath as IndexPath) as! ItemViewCell
            cell.nameLabel.text = " \(lifeItem.lifeName)"
            cell.nameLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lifeItem = lifes[indexPath.row]
        if lifeItem.lifeId == 0 {
            SwiftEventBus.post("goToSearch", sender: self.searchString)
        } else {
            performSegue(withIdentifier: "showVerseByLife", sender: lifeItem)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerseByLife" {
            if let verseLifeViewController  = segue.destination as? VerseByLifeViewController {
                let selectedLifeItem = sender as! Life
                verseLifeViewController.life = selectedLifeItem
                verseLifeViewController.fontSize = fontSize
                verseLifeViewController.languageId = languageId
                verseLifeViewController.translationId = translationId
                let backItem = UIBarButtonItem()
                backItem.title = "back".localized
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
}
