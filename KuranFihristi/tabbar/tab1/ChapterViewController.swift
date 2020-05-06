//
//  ChapterViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SQLite3
import AudioToolbox

class ChapterViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private let dataBase = DataBase()
    private var chapters = Array<Chapter>()
    private var fullChapters = Array<Chapter>()
    private var searchController = UISearchController()
    
    private var languageId = 1
    private var tranlationId = 154
    private var verseId = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let button = self.navigationItem.rightBarButtonItem {
            button.isEnabled = false
            button.tintColor = UIColor.clear
        }
        
        fullChapters = dataBase.getChapters(tranlationId: tranlationId)
        chapters = fullChapters
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        prepareSearchController()
        setupLongPressGesture() 
        
        tableView.tableFooterView = UIView()
    }
    
    func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.8
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            AudioServicesPlaySystemSound(1520) // 1519 - peek, 1521 - nope
            
            print("Long press on row, at \(indexPath!.row)")
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.middle)
            tableView.allowsMultipleSelection = true
            
            let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title: "Her hangi bir ayete git", style: .default) { (action) in
                let verseBy = self.dataBase.getRandomVerseBy(translationId: self.tranlationId)
                self.verseId = verseBy.verseId
                let openChapter = Chapter(chapterId: verseBy.chapterId, chapterName: verseBy.chapterName)
                self.performSegue(withIdentifier: "showVerses", sender: openChapter)
            }
            let icon = UIImage(systemName: "wand.and.stars")
            action.setValue(icon, forKey: "image")
            action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            actionSheetAlertController.addAction(action)
            
            
            let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheetAlertController.addAction(cancelActionButton)
            
            self.present(actionSheetAlertController, animated: true, completion: nil)
            
            
        }
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
            chapters = fullChapters.filter { (Chapter) -> Bool in
                let itemText = Chapter.chapterName.lowercased()
                return "\(Chapter.chapterId).".contains(searchText) || itemText.contains(loverSearch) || itemText.contains(textAz)
            }
            
            if searchText.count > 2 {
                chapters.insert(Chapter(chapterId: 0, chapterName: ""), at: 0)
            }
        } else {
            chapters = fullChapters
        }
        tableView.reloadData()
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        searchController.searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chapters.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chapterItem = chapters[indexPath.row]
        if chapterItem.chapterId == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chapterItemViewCell", for: indexPath as IndexPath) as! ItemViewCell
            cell.nameLabel.text = "\(chapterItem.chapterId). \(chapterItem.chapterName)"
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showVerses", sender: chapters[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerses" {
            if let verseController = segue.destination as? VerseViewController {
                let selectedChapterItem = sender as! Chapter
                verseController.verseId = verseId
                verseController.chapterId = selectedChapterItem.chapterId
                verseController.chapterName = selectedChapterItem.chapterName
                verseController.languageId = languageId
                verseController.tranlationId = tranlationId
                verseId = 1
                let backItem = UIBarButtonItem()
                backItem.title = "Geri"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
    
}



extension String {
    func replacingOccurrences(ofes: Array<String>, withes: Array<String>) -> String {
        var str = self
        for (index, of) in ofes.enumerated() {
            str = str.replacingOccurrences(of: of, with: withes[index])
        }
        return str
    }
}
