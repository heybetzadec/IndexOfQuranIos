//
//  SearchViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import AudioToolbox
import SwiftEventBus

class SearchViewController: UITableViewController , UISearchResultsUpdating, UISearchBarDelegate {
    
    var chapterName = ""
    var fontSize = 17
    var languageId = 1
    var translationId = 154
    var searchString = ""
    var darkMode = false
    
    private let funcs = Functions()
    private let dataBase = DataBase()
    private var verses = Array<Verse>()
    private var selectedVerses = Array<Verse>()
    private var searchController = UISearchController()
    private var bottomItems =  Array<BottomItem>()
    var timer = Timer()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        searchController.isActive = true
        searchController.isEditing = true
        searchController.searchBar.text = searchString
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let mainTabBar = self.tabBarController as! AppTabBarViewController
        self.searchString = mainTabBar.searchString
        mainTabBar.searchString = ""
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            print(timer)
            self.filter(searchText: self.searchString)
          }
        }
        
        if let button = self.navigationItem.rightBarButtonItem {
            button.isEnabled = false
            button.tintColor = UIColor.clear
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "search_all".localized
        
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
            
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.middle)
            tableView.allowsMultipleSelection = true
            self.appendVerse(insertVerse: verses[indexPath!.row])
            let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if darkMode {
                actionSheetAlertController.overrideUserInterfaceStyle = .dark
                actionSheetAlertController.view.tintColor = .white
            } else {
                actionSheetAlertController.overrideUserInterfaceStyle = .light
                actionSheetAlertController.view.tintColor = UIColor(red: 0, green: 103/255.0, blue: 91/255.0, alpha: 1.0)
            }
            
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
                self.funcs.showToast(message: "copied".localized, view: self.view)
                self.deselectAll()
            }
            icon =  UIImage(systemName: bottomItems[2].icon) ?? .add
            action.setValue(icon, forKey: "image")
            action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            actionSheetAlertController.addAction(action)
            
            
            // Pin selected
            action = UIAlertAction(title: bottomItems[3].name, style: .default) { (action) in
                self.dataBase.insertSavedVerse(verses: self.selectedVerses)
                self.funcs.showToast(message: "pinned".localized, view: self.view)
                self.deselectAll()
            }
            
            icon =  UIImage(systemName: bottomItems[3].icon) ?? .add
            action.setValue(icon, forKey: "image")
            action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            actionSheetAlertController.addAction(action)
            
            let cancelActionButton = UIAlertAction(title: "cancel".localized, style: .cancel, handler: { (action) in
                self.deselectAll()
            })
            actionSheetAlertController.addAction(cancelActionButton)
            
            self.present(actionSheetAlertController, animated: true, completion: nil)
            
            
        }
    }
    
    
    
    
    private func prepareSearchController() {
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
            verses = dataBase.getSearchVerses(searchWord: searchText, translationId: translationId)
            
        } else {
            verses = Array<Verse>()
        }
        tableView.reloadData()
    }
    
    
    private func deselectAll(){
        let selectedRows = self.tableView.indexPathsForSelectedRows
        for row in selectedRows! {
            self.tableView.deselectRow(at: row, animated: true)
        }
        selectedVerses = Array<Verse>()
        tableView.allowsMultipleSelection = false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let verseItem = verses[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchVerseViewCell", for: indexPath as IndexPath) as! VerseViewCell
        
        let attrStr = NSMutableAttributedString(string: "\(verseItem.chapterId):\(verseItem.verseId). \(verseItem.verseText)")
        let inputLength = attrStr.string.count
        let searchLength = searchString.count
        
        if verses.count > 0 {
            var range = NSRange(location: 0, length: attrStr.length)
            
            while (range.location != NSNotFound) {
                range = (attrStr.string as NSString).range(of: searchString, options: [.caseInsensitive], range: range)
                if (range.location != NSNotFound) {
                    attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemRed, range: NSRange(location: range.location, length: searchLength))
                    range = NSRange(location: range.location + range.length, length: inputLength - (range.location + range.length))
                }
            }
        }
        
        
        cell.verseTextLabel.attributedText = attrStr //"\(verseItem.verseId). \(verseItem.verseText)"
        cell.verseTextLabel.font = .systemFont(ofSize: CGFloat(fontSize))
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let removeItem = verses[indexPath.row]
        selectedVerses.removeAll { (Verse) -> Bool in
            Verse.chapterId == removeItem.chapterId && Verse.verseId == removeItem.verseId
        }
        if selectedVerses.count == 0 {
            tableView.allowsMultipleSelection =  false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let verseItem = verses[indexPath.row]
        if tableView.allowsMultipleSelection {
            self.appendVerse(insertVerse: verseItem)
            
        }
        
        if selectedVerses.count == 0 {
            let chapterName = self.dataBase.getChapterName(chapterId: verseItem.chapterId, translationId: self.translationId)
            SwiftEventBus.post("goToVerse", sender: VerseBy(chapterId: verseItem.chapterId, chapterName: chapterName, verseId: verseItem.verseId, verseText: ""))
//            performSegue(withIdentifier: "showVerseBySearch", sender: verses[indexPath.row])
        }
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showVerseBySearch" {
//            if let verseController = segue.destination as? VerseViewController {
//                let selectedVerseItem = sender as! Verse
//                verseController.verseId = selectedVerseItem.verseId
//                verseController.chapterId = selectedVerseItem.chapterId
//                verseController.chapterName = dataBase.getChapterName(chapterId: selectedVerseItem.chapterId, translationId: translationId)
//                verseController.languageId = languageId
//                verseController.translationId = translationId
//                let backItem = UIBarButtonItem()
//                backItem.title = "Geri"
//                navigationItem.backBarButtonItem = backItem
//            }
//        }
//    }
    
    
    private func appendVerse(insertVerse:Verse){
        let filtered = selectedVerses.filter { (Verse) -> Bool in
            Verse.chapterId == insertVerse.chapterId && Verse.verseId == insertVerse.verseId
        }
        if filtered.count == 0 {
            selectedVerses.append(insertVerse)
        }
    }
    
    
    
    private func getSelectedText() -> String {
        var text = ""
        selectedVerses.sort { (Verse1, Verse2) -> Bool in
            Verse1.verseId < Verse2.verseId
        }
        for verse in selectedVerses {
            let chapterName = dataBase.getChapterName(chapterId: verse.chapterId, translationId: translationId)
            text = "\(text)\(verse.verseText)\n\(verse.chapterId). \(chapterName), \(verse.verseId)\n\n"
        }
        if text != "" {
            let index = text.count - 2
            text = String(text.prefix(index))
        }
        return text
    }
    

    
}
