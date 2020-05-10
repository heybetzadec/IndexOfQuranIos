//
//  LetterViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class LetterViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private let dataBase = DataBase()
    private var letters = Array<Letter>()
    private var fullLetters = Array<Letter>()
    private var searchController = UISearchController()
    private var defaults = UserDefaults.standard
    private var searchString = ""
    
    private var languageId = 1
    private var translationId = 154
    private var fontSize = 17
    
    
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
                self.fullLetters = self.dataBase.getLetters(languageId: self.languageId)
                self.letters = self.fullLetters
                self.navigationItem.title = "dictionary".localized
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
        
        fullLetters = dataBase.getLetters(languageId: languageId)
        letters = fullLetters
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.title = "dictionary".localized
        
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
            letters = fullLetters.filter { (Letter) -> Bool in
                let itemText = Letter.letterName.lowercased()
                return itemText.contains(loverSearch) || itemText.contains(textAz)
            }
            
            if searchText.count > 2 {
                letters.insert(Letter(letterId: 0, letterName: ""), at: 0)
            }
        } else {
            letters = fullLetters
        }
        tableView.reloadData()
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        searchController.searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return letters.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let letterItem = letters[indexPath.row]
        if letterItem.letterId == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "letterItemViewCell", for: indexPath as IndexPath) as! ItemViewCell
            cell.nameLabel.text = " \(letterItem.letterName)"
            cell.nameLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let letterItem = letters[indexPath.row]
        if letterItem.letterId == 0 {
            SwiftEventBus.post("goToSearch", sender: self.searchString)
        } else {
            performSegue(withIdentifier: "showWords", sender: letters[indexPath.row])
        }
        
        if !searchString.isEmpty {
            DispatchQueue.main.async {
                self.searchController.searchBar.text = ""
                self.searchController.isActive = false
                self.searchController.isEditing = false
                self.letters = self.fullLetters
                self.tableView.reloadData()
              }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWords" {
            if let wordController = segue.destination as? WordViewController {
                let selectedLetterItem = sender as! Letter
                wordController.letter = selectedLetterItem
                wordController.languageId = languageId
                wordController.fontSize = fontSize
                wordController.translationId = translationId
                let backItem = UIBarButtonItem()
                backItem.title = "back".localized
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
}
