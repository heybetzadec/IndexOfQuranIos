//
//  PhraseViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class PhraseViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    private let dataBase = DataBase()
    private var phrases = Array<Phrase>()
    private var fullPhrases = Array<Phrase>()
    private var searchController = UISearchController()
    
    var topic = Topic()
    var fontSize = 17
    var languageId = 1
    var translationId = 154
    var searchString = ""
    var darkMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            self.translationId = option.translationId
            
            if option.languageId != self.languageId {
                self.languageId = option.languageId
                self.fullPhrases = self.dataBase.getPhrase(topicId: self.topic.topicId, languageId: self.languageId)
                self.phrases = self.fullPhrases
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
        
        fullPhrases = dataBase.getPhrase(topicId: topic.topicId, languageId: languageId)
        phrases = fullPhrases
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "\(topic.topicName)"
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
        if !searchText.isEmpty {
            let loverSearch = searchText.lowercased()
            let textAz = loverSearch.replacingOccurrences(ofes: ["e","i"], withes: ["ə", "i̇"])
            phrases = fullPhrases.filter { (Phrase) -> Bool in
                let itemText = Phrase.phraseName.lowercased()
                return itemText.contains(loverSearch) || itemText.contains(textAz)
            }
            
            if searchText.count > 2 {
                phrases.insert(Phrase(phraseId: 0, phraseName: ""), at: 0)
            }
            
        } else {
            phrases = fullPhrases
        }
        tableView.reloadData()
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        searchController.searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return phrases.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let phraseItem = phrases[indexPath.row]
        if phraseItem.phraseId == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "phraseItemViewCell", for: indexPath as IndexPath) as! ItemViewCell
            cell.nameLabel.text = " \(phraseItem.phraseName)"
            cell.nameLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let phraseItem = phrases[indexPath.row]
        if phraseItem.phraseId == 0 {
            SwiftEventBus.post("goToSearch", sender: self.searchString)
        } else {
            performSegue(withIdentifier: "showVerseByTopic", sender: phrases[indexPath.row])
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerseByTopic" {
            if let verseByTopicController = segue.destination as? VerseByTopicViewController {
                let selectedPhraseItem = sender as! Phrase
                verseByTopicController.phrase = selectedPhraseItem
                verseByTopicController.topic = topic
                verseByTopicController.fontSize = fontSize
                verseByTopicController.languageId = languageId
                verseByTopicController.translationId = translationId
                verseByTopicController.darkMode = darkMode
                let backItem = UIBarButtonItem()
                backItem.title = "back".localized
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
}
