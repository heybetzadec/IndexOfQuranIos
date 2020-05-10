//
//  VerseViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import AudioToolbox
import SwiftEventBus

class VerseViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var fontSize = 17
    var chapterName = ""
    var verseId = 1
    var chapterId = 0
    var languageId = 0
    var translationId = 0
    var searchString = ""

    private let funcs = Functions()
    private let dataBase = DataBase()
    private var verses = Array<Verse>()
    private var fullVerses = Array<Verse>()
    private var selectedVerses = Array<Verse>()
    private var searchController = UISearchController()
    private var bottomItems =  Array<BottomItem>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            
            if self.translationId != option.translationId {
                self.translationId = option.translationId
                self.fullVerses = self.dataBase.getVerses(chapterId: self.chapterId, translationId: self.translationId)
                self.verses = self.fullVerses
                self.tableView.reloadData()
                
                self.chapterName = self.dataBase.getChapterName(chapterId: self.chapterId, translationId: self.translationId)
                self.navigationItem.title = "\(self.chapterId). \(self.chapterName)"
                
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
        
        fullVerses = dataBase.getVerses(chapterId: chapterId, translationId: translationId)
        verses = fullVerses
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "\(chapterId). \(chapterName)"
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        bottomItems = funcs.getDefaultBottomItems()
        
        prepareSearchController()
        setupLongPressGesture()
        
        tableView.scrollToRow(at: IndexPath(row: verseId - 1, section: 0), at: .top, animated: false)
        
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
            
            cell.verseTextLabel.attributedText = attrStr
            cell.verseTextLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            
            return cell
        }
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
        
        if verseItem.chapterId == 0 {
            SwiftEventBus.post("goToSearch", sender: searchString)
        } else {
            if tableView.allowsMultipleSelection {
                self.appendVerse(insertVerse: verses[indexPath.row])
            }
            if selectedVerses.count == 0 {
                performSegue(withIdentifier: "showVerseDetail", sender: verseItem)
            }
        }
        
        if !searchString.isEmpty {
            DispatchQueue.main.async {
                self.searchController.searchBar.text = ""
                self.searchController.isActive = false
                self.searchController.isEditing = false
                self.verses = self.fullVerses
                self.tableView.reloadData()
              }
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerseDetail" {
            if let verseDetailController = segue.destination as? VerseDetailViewController {
                let selectedVerseItem = sender as! Verse
                verseDetailController.fontSize = fontSize
                verseDetailController.verseId = selectedVerseItem.verseId
                verseDetailController.chapterId = chapterId
                verseDetailController.chapterName = chapterName
                verseDetailController.languageId = languageId
                verseDetailController.translationId = translationId
                let backItem = UIBarButtonItem()
                backItem.title = "back".localized
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
    
    private func appendVerse(insertVerse:Verse){
        let filtered = selectedVerses.filter { (Verse) -> Bool in
            Verse.chapterId == insertVerse.chapterId && Verse.verseId == insertVerse.verseId
        }
        if filtered.count == 0 {
            selectedVerses.append(insertVerse)
        }
    }
    
    
    private func deselectAll(){
        let selectedRows = self.tableView.indexPathsForSelectedRows
        for row in selectedRows! {
            self.tableView.deselectRow(at: row, animated: true)
        }
        selectedVerses = Array<Verse>()
        tableView.allowsMultipleSelection = false
    }
    
    
    private func getSelectedText() -> String {
        var text = ""
        selectedVerses.sort { (Verse1, Verse2) -> Bool in
            Verse1.verseId < Verse2.verseId
        }
        for verse in selectedVerses {
            text = "\(text)\(verse.verseText)\n\(chapterId). \(chapterName), \(verse.verseId)\n\n"
        }
        if text != "" {
            let index = text.count - 2
            text = String(text.prefix(index))
        }
        return text
    }
    
//    func showToast(message : String) {
//        let h = self.view.frame.size.height
//        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: h - h/2 , width: 150, height: 35))
//        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        toastLabel.textColor = UIColor.white
//        toastLabel.textAlignment = .center;
//        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
//        toastLabel.text = message
//        toastLabel.alpha = 1.0
//        toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds  =  true
//        self.view.superview!.addSubview(toastLabel)
//        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
//            toastLabel.alpha = 0.0
//        }, completion: {(isCompleted) in
//            toastLabel.removeFromSuperview()
//        })
//    }
    
}
