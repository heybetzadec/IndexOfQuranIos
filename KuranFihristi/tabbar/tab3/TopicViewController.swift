//
//  TopicViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class TopicViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private let dataBase = DataBase()
    private var topics = Array<Topic>()
    private var fullTopics = Array<Topic>()
    private var searchController = UISearchController()
    private var defaults = UserDefaults.standard
    private var searchString = ""
    
    private var languageId = 1
    private var translationId = 154
    private var fontSize = 17
    private var darkMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        languageId = defaults.integer(forKey: "languageId")
        translationId = defaults.integer(forKey: "translationId")
        fontSize = defaults.integer(forKey: "fontSize")
        darkMode = defaults.bool(forKey: "darkMode")
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            self.translationId = option.translationId
            
            if option.languageId != self.languageId {
                self.languageId = option.languageId
                self.fullTopics = self.dataBase.getTopics(languageId: self.languageId)
                self.topics = self.fullTopics
                self.navigationItem.title = "topics".localized
                self.tableView.reloadData()
            }
            
            if self.fontSize != option.fontSize {
                self.fontSize = option.fontSize
                self.tableView.reloadData()
            }
            
            self.darkMode = option.darkMode
        }
        
        if let button = self.navigationItem.rightBarButtonItem {
            button.isEnabled = false
            button.tintColor = UIColor.clear
        }
        
        fullTopics = dataBase.getTopics(languageId: languageId)
        topics = fullTopics
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.title = "topics".localized
        
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
        self.searchString = searchText
        if !searchText.isEmpty {
            let loverSearch = searchText.lowercased()
            let textAz = loverSearch.replacingOccurrences(ofes: ["e","i"], withes: ["ə", "i̇"])
            topics = fullTopics.filter { (Topic) -> Bool in
                let itemText = Topic.topicName.lowercased()
                return itemText.contains(loverSearch) || itemText.contains(textAz)
            }
            
            if searchText.count > 2 {
                topics.insert(Topic(topicId: 0, topicName: ""),  at: 0)
            }
        } else {
            topics = fullTopics
        }
        tableView.reloadData()
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        searchController.searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if topics.count == 0 {
            TableViewHelper.EmptyMessage(message: "This section is not ready\nfor the selected language yet!", viewController: self)
            return 0
        } else {
            return topics.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topicItem = topics[indexPath.row]
        if topicItem.topicId == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
            cell.searchLabel.text = "search_all".localized
            cell.searchLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "topicItemViewCell", for: indexPath as IndexPath) as! ItemViewCell
            cell.nameLabel.text = " \(topicItem.topicName)"
            cell.nameLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicItem = topics[indexPath.row]
        if topicItem.topicId == 0 {
            SwiftEventBus.post("goToSearch", sender: self.searchString)
        } else {
            performSegue(withIdentifier: "showPhrases", sender: topicItem)
        }
        if !searchString.isEmpty {
            DispatchQueue.main.async {
                self.filter(searchText: "")
                self.searchController.isActive = false
                self.searchController.isEditing = false
                self.topics = self.fullTopics
                self.tableView.reloadData()
              }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhrases" {
            if let phraseViewController  = segue.destination as? PhraseViewController {
                let selectedPhraseItem = sender as! Topic
                phraseViewController.topic = selectedPhraseItem
                phraseViewController.fontSize = fontSize
                phraseViewController.languageId = languageId
                phraseViewController.translationId = translationId
                phraseViewController.darkMode = darkMode
                let backItem = UIBarButtonItem()
                backItem.title = "back".localized
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
}
