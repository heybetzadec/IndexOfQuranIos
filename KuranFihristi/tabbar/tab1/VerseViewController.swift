//
//  VerseViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class VerseViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var chapterName = ""
    var chapterId = 0
    var languageId = 0
    var tranlationId = 0
    var searchString = ""
    
    private let dataBase = DataBase()
    private var verses = Array<Verse>()
    private var fullVerses = Array<Verse>()
    private var searchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let button = self.navigationItem.rightBarButtonItem {
            button.isEnabled = false
            button.tintColor = UIColor.clear
        }
        
        fullVerses = dataBase.getVerses(chapterId: chapterId, tranlationId: tranlationId)
        verses = fullVerses
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "\(chapterId). \(chapterName)"
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        prepareSearchController()
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
        searchString = searchText
        if !searchText.isEmpty {
            let loverSearch = searchText.lowercased()
            verses = fullVerses.filter { (verse) -> Bool in
                let itemText = verse.verseText.lowercased()
                return "\(verse.verseId).".contains(searchText) || itemText.contains(loverSearch)
            }
            
            if searchText.count > 2 {
                verses.insert(Verse(chapterId: 0, verseId: 0, verseText: ""), at: 0)
            }
            
        } else {
            verses = fullVerses
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let verseItem = verses[indexPath.row]
        if verseItem.verseId == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "verseViewCell", for: indexPath as IndexPath) as! VerseViewCell
            
            let attrStr = NSMutableAttributedString(string: "\(verseItem.verseId). \(verseItem.verseText)")
            let inputLength = attrStr.string.count
            let searchLength = searchString.count
            var range = NSRange(location: 0, length: attrStr.length)

            while (range.location != NSNotFound) {
                range = (attrStr.string as NSString).range(of: searchString, options: [.caseInsensitive], range: range)
                if (range.location != NSNotFound) {
                    attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemRed, range: NSRange(location: range.location, length: searchLength))
                    range = NSRange(location: range.location + range.length, length: inputLength - (range.location + range.length))
                }
            }
            
            cell.verseTextLabel.attributedText = attrStr //"\(verseItem.verseId). \(verseItem.verseText)"
            return cell
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showVerseDetail", sender: verses[indexPath.row])
//        let verseItem = verses[indexPath.row]
//        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
//        let verseDetailController = storyBoard.instantiateViewController(withIdentifier: "verseDetailViewController") as! VerseDetailViewController
//        verseDetailController.verseId = verseItem.verseId
//        verseDetailController.chapterId = chapterId
//        verseDetailController.chapterName = chapterName
//        verseDetailController.languageId = languageId
//        verseDetailController.tranlationId = tranlationId
//        self.navigationController?.pushViewController(verseDetailController, animated: false)
//        filter(searchText: "")
//        navigationItem.searchController?.isActive = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerseDetail" {
            if let verseDetailController = segue.destination as? VerseDetailViewController {
                let selectedVerseItem = sender as! Verse
                verseDetailController.verseId = selectedVerseItem.verseId
                verseDetailController.chapterId = chapterId
                verseDetailController.chapterName = chapterName
                verseDetailController.languageId = languageId
                verseDetailController.tranlationId = tranlationId
                let backItem = UIBarButtonItem()
                backItem.title = "Geri"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }

}
