//
//  NameViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class NameViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private let dataBase = DataBase()
    private var names = Array<Name>()
    private var fullNames = Array<Name>()
    private var searchController = UISearchController()
    private var defaults = UserDefaults.standard
    private var searchString = ""
    
    private var languageId = 1
    private var fontSize = 17
    private var translationId = 154
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        languageId = defaults.integer(forKey: "languageId")
        translationId = defaults.integer(forKey: "translationId")
        fontSize = defaults.integer(forKey: "fontSize")
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            
            if option.languageId != self.languageId {
                self.languageId = option.languageId
                self.fullNames = self.dataBase.getNames(languageId: self.languageId)
                self.names = self.fullNames
                self.navigationItem.title = "names_title".localized
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
        
        fullNames = dataBase.getNames(languageId: languageId)
        names = fullNames
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.title = "names_title".localized
        prepareSearchController()
        
        tableView.tableFooterView = UIView()
    }
    
    
    func prepareSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "\("search".localized)..."
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
        searchString = searchText
        if !searchText.isEmpty {
            let loverSearch = searchText.lowercased()
            let textAz = loverSearch.replacingOccurrences(ofes: ["e","i"], withes: ["ə", "i̇"])
            names = fullNames.filter { (Name) -> Bool in
                let itemText = Name.nameText.lowercased()
                let itemDesc = Name.nameDescription.lowercased()
                return itemDesc.contains(searchText) || itemText.contains(loverSearch) || itemText.contains(textAz)
            }
            if searchText.count > 2 {
                names.insert(Name(nameId: 0, nameText: "", nameDescription: ""), at: 0)
            }
        } else {
            names = fullNames
        }
        tableView.reloadData()
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        searchController.searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return names.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nameItem = names[indexPath.row]
        if nameItem.nameId == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
            cell.searchLabel.text = "search_all".localized
            cell.searchLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameViewCell", for: indexPath as IndexPath) as! ItemDetailViewCell
            cell.titleLabel.text = nameItem.nameText
            cell.subTitleLabel.text = nameItem.nameDescription
            cell.titleLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            cell.subTitleLabel.font = .systemFont(ofSize: CGFloat(fontSize-3))
            
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nameItem = names[indexPath.row]
        if nameItem.nameId == 0 {
            SwiftEventBus.post("goToSearch", sender: self.searchString)
        } else {
            performSegue(withIdentifier: "nameDetail", sender: nameItem)
        }
        if !searchString.isEmpty {
            DispatchQueue.main.async {
                self.filter(searchText: "")
                self.searchController.isActive = false
                self.searchController.isEditing = false
                self.names = self.fullNames
                self.tableView.reloadData()
              }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nameDetail" {
            if let nameController = segue.destination as? NameDetailViewController {
                nameController.name = sender as! Name
                nameController.fontSize = fontSize
                nameController.languageId = languageId
                nameController.translationId = translationId
                let backItem = UIBarButtonItem()
                backItem.title = "back".localized
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
    
}
