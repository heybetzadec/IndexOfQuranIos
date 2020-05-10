//
//  VerseByWordViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import AudioToolbox
import SwiftEventBus

class VerseByWordViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private let dataBase = DataBase()
    private var versesBy = Array<VerseBy>()
    private var fullVersesBy = Array<VerseBy>()
    private var selectedVersesBy = Array<VerseBy>()
    private var searchController = UISearchController()
    private var bottomItems =  Array<BottomItem>()
    private var funcs = Functions()
    
    var letter = Letter()
    var word = Word()
    var fontSize = 17
    var languageId = 0
    var translationId = 0
    var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            
            if option.languageId != self.languageId || self.translationId != option.translationId{
                self.languageId = option.languageId
                self.translationId = option.translationId
                self.fullVersesBy = self.dataBase.getVerseByWords(letterId: self.letter.letterId, wordId: self.word.wordId, languageId: self.languageId, translationId: self.translationId)
                self.versesBy = self.fullVersesBy
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
        
        fullVersesBy = dataBase.getVerseByWords(letterId: letter.letterId, wordId: word.wordId, languageId: languageId, translationId: translationId)
        versesBy = fullVersesBy
        
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "\(word.wordName)"
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        let funcs = Functions()
        bottomItems = funcs.getDefaultBottomItems()
        
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
            self.appendVerseBy(insertVerse: versesBy[indexPath!.row])
            let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // Select others
            var action = UIAlertAction(title: bottomItems[0].name, style: .default) { (action) in
                
            }
            var icon = UIImage(systemName: bottomItems[0].icon)
            action.setValue(icon, forKey: "image")
            action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            actionSheetAlertController.addAction(action)
            
            // Share selected
            action = UIAlertAction(title: bottomItems[1].name, style: .default) { (action) in
                let text = self.getSelectedText()
                let textShare = [ text ]
                let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
                self.deselectAll()
            }
            icon = UIImage(systemName: bottomItems[1].icon) ?? .add
            action.setValue(icon, forKey: "image")
            action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            actionSheetAlertController.addAction(action)
            
            // Copy selected
            action = UIAlertAction(title: bottomItems[2].name, style: .default) { (action) in
                UIPasteboard.general.string = self.getSelectedText()
                self.funcs.showToast(message: "Kopyalandı", view: self.view)
                let selectedRows = self.tableView.indexPathsForSelectedRows
                for row in selectedRows! {
                    self.tableView.deselectRow(at: row, animated: true)
                }
                self.deselectAll()
            }
            icon =  UIImage(systemName: bottomItems[2].icon) ?? .add
            action.setValue(icon, forKey: "image")
            action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            actionSheetAlertController.addAction(action)
            
            
            // Pin selected
            action = UIAlertAction(title: bottomItems[3].name, style: .default) { (action) in
                var verses = Array<Verse>()
                for verseBy in self.selectedVersesBy {
                    verses.append(Verse(chapterId: verseBy.chapterId, verseId: verseBy.verseId, verseText: verseBy.verseText))
                }
                self.dataBase.insertSavedVerse(verses: verses)
                self.funcs.showToast(message: "Pinlendi", view: self.view)
                self.deselectAll()
            }
            icon =  UIImage(systemName: bottomItems[3].icon) ?? .add
            action.setValue(icon, forKey: "image")
            action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            actionSheetAlertController.addAction(action)
            
            let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheetAlertController.addAction(cancelActionButton)
            
            self.present(actionSheetAlertController, animated: true, completion: nil)
            
            
        }
    }
    
    
    private func prepareSearchController() {
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
            versesBy = fullVersesBy.filter { (verse) -> Bool in
                let itemText = verse.verseText.lowercased()
                return "\(verse.verseId).".contains(searchText) || itemText.contains(loverSearch)
            }
            
            if searchText.count > 2 {
                versesBy.insert(VerseBy(chapterId: 0, chapterName: "", verseId: 0, verseText: ""), at: 0)
            }
            
        } else {
            versesBy = fullVersesBy
        }
        tableView.reloadData()
    }
    
    private func deselectAll(){
        let selectedRows = self.tableView.indexPathsForSelectedRows ?? [IndexPath(row: 0, section: 0)]
        for row in selectedRows {
            self.tableView.deselectRow(at: row, animated: true)
        }
        selectedVersesBy = Array<VerseBy>()
        tableView.allowsMultipleSelection = false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return versesBy.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let verseItem = versesBy[indexPath.row]
        if verseItem.verseId == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "verseByWordViewCell", for: indexPath as IndexPath) as! VerseByViewCell
            
            let attrStr = NSMutableAttributedString(string: "\(verseItem.verseText)")
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
            
            cell.nameLabel.text = "\(verseItem.chapterId). \(verseItem.chapterName), \(verseItem.verseId)"
            cell.verseLabel.attributedText = attrStr //"\(verseItem.verseId). \(verseItem.verseText)"
            cell.nameLabel.font = .boldSystemFont(ofSize: CGFloat(fontSize))
            cell.verseLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let removeItem = versesBy[indexPath.row]
        selectedVersesBy.removeAll { (Verse) -> Bool in
            Verse.chapterId == removeItem.chapterId && Verse.verseId == removeItem.verseId
        }
        if selectedVersesBy.count == 0 {
            tableView.allowsMultipleSelection =  false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let verseByItem = versesBy[indexPath.row]
        if tableView.allowsMultipleSelection {
            self.appendVerseBy(insertVerse: verseByItem)
            
        }
        
        if selectedVersesBy.count == 0 {
            if verseByItem.verseId == 0 {
                SwiftEventBus.post("goToSearch", sender: self.searchString)
            } else {
                SwiftEventBus.post("goToVerse", sender: verseByItem)
            }
            
            if !searchString.isEmpty {
                DispatchQueue.main.async {
                    self.searchController.searchBar.text = ""
                    self.searchController.isActive = false
                    self.searchController.isEditing = false
                    self.versesBy = self.fullVersesBy
                    self.tableView.reloadData()
                }
            }
            
        }
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showVerseFromByWord" {
//            if let verseController = segue.destination as? VerseViewController {
//                let selectedVerseByItem = sender as! VerseBy
//                verseController.verseId = selectedVerseByItem.verseId
//                verseController.chapterId = selectedVerseByItem.chapterId
//                verseController.chapterName = selectedVerseByItem.chapterName
//                verseController.languageId = languageId
//                verseController.translationId = translationId
//                let backItem = UIBarButtonItem()
//                backItem.title = "back".localized
//                navigationItem.backBarButtonItem = backItem
//            }
//        }
//    }
    
    
    private func appendVerseBy(insertVerse:VerseBy){
        let filtered = selectedVersesBy.filter { (Verse) -> Bool in
            Verse.chapterId == insertVerse.chapterId && Verse.verseId == insertVerse.verseId
        }
        if filtered.count == 0 {
            selectedVersesBy.append(insertVerse)
        }
    }
    
    
    
    private func getSelectedText() -> String {
        var text = ""
        selectedVersesBy.sort { (Verse1, Verse2) -> Bool in
            Verse1.verseId < Verse2.verseId
        }
        for verse in selectedVersesBy {
            text = "\(text)\(verse.verseText)\n\(verse.chapterId). \(verse.chapterName), \(verse.verseId)\n\n"
        }
        if text != "" {
            let index = text.count - 2
            text = String(text.prefix(index))
        }
        return text
    }
    
//    func showToast(message : String) {
//        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.tableView.contentSize.height - 150 , width: 150, height: 35))
//        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        toastLabel.textColor = UIColor.white
//        toastLabel.textAlignment = .center;
//        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
//        toastLabel.text = message
//        toastLabel.alpha = 1.0
//        toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds  =  true
//        self.view.addSubview(toastLabel)
//        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
//            toastLabel.alpha = 0.0
//        }, completion: {(isCompleted) in
//            toastLabel.removeFromSuperview()
//        })
//    }
    
    
}
