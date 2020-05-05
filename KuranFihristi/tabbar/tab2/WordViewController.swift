//
//  WordViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class WordViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    private let dataBase = DataBase()
    private var words = Array<Word>()
    private var fullWords = Array<Word>()
    private var searchController = UISearchController()
    
    var letter = Letter()
    var languageId = 0
    var tranlationId = 0
    var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let button = self.navigationItem.rightBarButtonItem {
            button.isEnabled = false
            button.tintColor = UIColor.clear
        }
        
        fullWords = dataBase.getWords(letterId: letter.letterId, languageId: languageId)
        words = fullWords
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "\(letter.letterName)"
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
                 words = fullWords.filter { (Word) -> Bool in
                     let itemText = Word.wordName.lowercased()
                     return itemText.contains(loverSearch) || itemText.contains(textAz)
                 }
                 
                 if searchText.count > 2 {
                     words.insert(Word(wordId: 0, wordName: ""), at: 0)
                 }
             } else {
                 words = fullWords
             }
             tableView.reloadData()
         }
         
         
         @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
             searchController.searchBar.endEditing(true)
         }
         
         override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
             // #warning Incomplete implementation, return the number of rows
             return words.count
         }

        
         override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
             let wordItem = words[indexPath.row]
             if wordItem.wordId == 0 {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
                 return cell
             } else {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "wordViewCell", for: indexPath as IndexPath) as! WordViewCell
                 cell.wordNameLabel.text = " \(wordItem.wordName)"
                 return cell
             }
         }
         
         
         override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
             performSegue(withIdentifier: "showVerseByWord", sender: words[indexPath.row])
         }
         
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             if segue.identifier == "showVerseByWord" {
                 if let verseByWordController = segue.destination as? VerseByWordViewController {
                     let selectedWordItem = sender as! Word
                     verseByWordController.word = selectedWordItem
                     verseByWordController.letter = letter
                     verseByWordController.languageId = languageId
                     verseByWordController.tranlationId = tranlationId
                     let backItem = UIBarButtonItem()
                     backItem.title = "Geri"
                     navigationItem.backBarButtonItem = backItem
                 }
             }
         }

    }
