//
//  ChapterViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import AudioToolbox
import SwiftEventBus
import UserNotifications

class ChapterViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UNUserNotificationCenterDelegate {
    
    private let dataBase = DataBase()
    private var chapters = Array<Chapter>()
    private var fullChapters = Array<Chapter>()
    private var searchController = UISearchController()
    private var defaults = UserDefaults.standard
    private var savedVerse = Verse(chapterId: 0, verseId: 0, verseText: "")
    private var fromSavedVerse = false
    
    var languageId = 1
    var translationId = 154
    var selectedOrder = 0
    var fontSize = 17
    var darkMode = false
    var systemDarkMode = true
    var selectedInterfaceMode = 0
    var verseId = 1
    var searchString = ""
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("bura isledi")
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo

        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")

            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")

            case "show":
                // the user tapped our "show more info…" button
                print("Show more information…")

            default:
                break
            }
        }

        // you must call the completion handler when you're done
        completionHandler()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
//        if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive)
//        {
//            // user has tapped notification
//            print("user has tapped notification")
//        }
//        else
//        {
//            // user opened app from app icon
//            print("user opened app from app icon")
//        }
        
        if let button = self.navigationItem.rightBarButtonItem {
            button.isEnabled = false
            button.tintColor = UIColor.clear
        }
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                systemDarkMode = false
                defaults.set(false, forKey: "systemInterfaceDark")
            case .dark:
                systemDarkMode = true
                defaults.set(true, forKey: "systemInterfaceDark")
        @unknown default:
            systemDarkMode = false
            defaults.set(false, forKey: "systemInterfaceDark")
        }
        
        
        if !defaults.bool(forKey: "opened") {
            var selectedLanguage = 0
            let languageCode:String = Locale.current.languageCode ?? "tr"
            switch languageCode {
            case "tr":
                languageId = 1
                selectedLanguage = 2
            case "az":
                languageId = 2
                selectedLanguage = 0
            case "ru":
                languageId = 3
                selectedLanguage = 3
            case "en":
                languageId = 4
                selectedLanguage = 1
            default:
                languageId = 1
                selectedLanguage = 2
            }

            let translations = dataBase.getTranslations(languageId: languageId)
            translationId = translations.first!.translationId
            
            fontSize = 17
            
            defaults.set(selectedLanguage, forKey: "selectedLanguage")
            defaults.set(languageId, forKey: "languageId")
            defaults.set(translationId, forKey: "translationId")
            defaults.set(true, forKey: "opened")
            
            defaults.set(3, forKey: "selectedFontSize")
            defaults.set(fontSize, forKey: "fontSize")
            defaults.set(languageCode, forKey: "i18n_language")
            selectedInterfaceMode = 0
        } else {
            languageId = defaults.integer(forKey: "languageId")
            translationId = defaults.integer(forKey: "translationId")
            fontSize = defaults.integer(forKey: "fontSize")
            selectedOrder = defaults.integer(forKey: "selectedOrder")
            selectedInterfaceMode = defaults.integer(forKey: "selectedInterfaceMode")
            let savedChapterId = defaults.integer(forKey: "savedChapterId")
            let savedVerseId = defaults.integer(forKey: "savedVerseId")
            savedVerse.chapterId = savedChapterId
            savedVerse.verseId = savedVerseId
        }
        
        switch selectedInterfaceMode {
        case 0:
            SwiftEventBus.post("darkMode", sender: systemDarkMode)
            darkMode = systemDarkMode
        case 1:
            SwiftEventBus.post("darkMode", sender: false)
            darkMode = false
        case 2:
            SwiftEventBus.post("darkMode", sender: true)
            darkMode = true
        default:
            SwiftEventBus.post("darkMode", sender: systemDarkMode)
            darkMode = systemDarkMode
        }

        defaults.set(darkMode, forKey: "darkMode")
        
//        if selectedInterfaceMode == 0 {
//            SwiftEventBus.post("darkMode", sender: darkMode)
//        }
        
        tabBarController?.viewControllers?[0].tabBarItem.title = "chapters".localized
        tabBarController?.viewControllers?[1].tabBarItem.title = "dictionary".localized
        tabBarController?.viewControllers?[2].tabBarItem.title = "topics".localized
        tabBarController?.viewControllers?[3].tabBarItem.title = "names".localized
        tabBarController?.viewControllers?[4].tabBarItem.title = "other".localized
        
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            if option.selectedOrder != self.selectedOrder  || option.translationId != self.translationId{
                self.translationId = option.translationId
                self.selectedOrder = option.selectedOrder
                self.fullChapters = self.dataBase.getChapters(translationId: self.translationId, selectedOrder: self.selectedOrder)
                self.chapters = self.fullChapters
            }
            self.fontSize = option.fontSize
            self.darkMode = option.darkMode
            self.tableView.reloadData()
            
            self.navigationItem.title = "chapters".localized
        }
        
        SwiftEventBus.onMainThread(self, name:"goToVerse") { result in
            let goToVerseBy = result?.object as! VerseBy
            let mainTabBar = self.tabBarController as! AppTabBarViewController
            mainTabBar.selectedIndex = 0
            self.navigationController?.popToRootViewController(animated: true)
            self.verseId = goToVerseBy.verseId
            _ = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { timer in
                 self.performSegue(withIdentifier: "showVerses", sender: Chapter(chapterId: goToVerseBy.chapterId, chapterName: goToVerseBy.chapterName))
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name:"savedVerse") { result in
            let verse = result?.object as! Verse
            self.savedVerse = verse
            self.tableView.reloadData()
        }
        
        if savedVerse.chapterId != 0 {
            let chapterName = self.dataBase.getChapterName(chapterId: self.savedVerse.chapterId, translationId: self.translationId)
            self.verseId = self.savedVerse.verseId
            self.fromSavedVerse = true
            self.performSegue(withIdentifier: "showVerses", sender: Chapter(chapterId: self.savedVerse.chapterId, chapterName: chapterName))
        }
        
        
        fullChapters = dataBase.getChapters(translationId: translationId, selectedOrder: selectedOrder)
        chapters = fullChapters
        
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.title = "chapters".localized
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
            
            let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if darkMode {
                actionSheetAlertController.overrideUserInterfaceStyle = .dark
                actionSheetAlertController.view.tintColor = .white
            } else {
                actionSheetAlertController.overrideUserInterfaceStyle = .light
                actionSheetAlertController.view.tintColor = UIColor(red: 0, green: 103/255.0, blue: 91/255.0, alpha: 1.0)
            }
            
            var action = UIAlertAction(title: "random_ayat".localized, style: .default) { (action) in
                let verseBy = self.dataBase.getRandomVerseBy(translationId: self.translationId)
                self.verseId = verseBy.verseId
                let openChapter = Chapter(chapterId: verseBy.chapterId, chapterName: verseBy.chapterName)
                self.performSegue(withIdentifier: "showVerses", sender: openChapter)
            }
            let icon = UIImage(systemName: "wand.and.stars")
            action.setValue(icon, forKey: "image")
            action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            actionSheetAlertController.addAction(action)
            
            if self.savedVerse.chapterId != 0 {
                action = UIAlertAction(title: "go_to_mark".localized, style: .default) { (action) in
                    let chapterName = self.dataBase.getChapterName(chapterId: self.savedVerse.chapterId, translationId: self.translationId)
                    self.verseId = self.savedVerse.verseId
                    self.performSegue(withIdentifier: "showVerses", sender: Chapter(chapterId: self.savedVerse.chapterId, chapterName: chapterName))
                }
                let icon = UIImage(systemName: "bookmark")
                action.setValue(icon, forKey: "image")
                action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                actionSheetAlertController.addAction(action)
            }
            
            let cell = tableView.cellForRow(at: indexPath!)
            
            if cell?.accessoryType == .checkmark {
                action = UIAlertAction(title: "unmark_ayat".localized , style: .default) { (action) in
                    self.savedVerse = Verse(chapterId: 0, verseId: 0, verseText: "")
                    self.defaults.set(0, forKey: "savedChapterId")
                    self.defaults.set(0, forKey: "savedVerseId")
                    self.tableView.reloadData()
                    self.deselectAll()
                }
                let icon = UIImage(systemName: "xmark.circle")
                action.setValue(icon, forKey: "image")
                action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                actionSheetAlertController.addAction(action)
            }
            
            
             let cancelActionButton = UIAlertAction(title: "cancel".localized, style: .cancel, handler: { (action) in
                self.deselectAll()
             })
            actionSheetAlertController.addAction(cancelActionButton)
            
            self.present(actionSheetAlertController, animated: true, completion: nil)
            
        }
    
    }
    
    private func deselectAll(){
        let selectedRows = self.tableView.indexPathsForSelectedRows
        if selectedRows != nil {
            for row in selectedRows! {
                self.tableView.deselectRow(at: row, animated: true)
            }
        }
        
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
            cell.searchLabel.text = "search_all".localized
            cell.searchLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chapterItemViewCell", for: indexPath as IndexPath) as! ItemViewCell
            cell.nameLabel.text = "\(chapterItem.chapterId). \(chapterItem.chapterName)"
            cell.nameLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            if chapterItem.chapterId == savedVerse.chapterId {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .disclosureIndicator
            }
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chapterItem = chapters[indexPath.row]
        if chapterItem.chapterId == 0 {
            SwiftEventBus.post("goToSearch", sender: searchString)
        } else {
            performSegue(withIdentifier: "showVerses", sender: chapters[indexPath.row])
        }
        
        if !searchString.isEmpty {
            DispatchQueue.main.async {
                self.searchController.searchBar.text = ""
                self.searchController.isActive = false
                self.searchController.isEditing = false
                self.chapters = self.fullChapters
                self.tableView.reloadData()
              }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerses" {
            if let verseController = segue.destination as? VerseViewController {
                let selectedChapterItem = sender as! Chapter
                verseController.verseId = verseId
                verseController.fontSize = fontSize
                verseController.darkMode = darkMode
                verseController.chapterId = selectedChapterItem.chapterId
                verseController.chapterName = selectedChapterItem.chapterName
                verseController.languageId = languageId
                verseController.savedVerse = savedVerse
                verseController.translationId = translationId
                verseController.fromSavedVerse = fromSavedVerse
                verseId = 1
                fromSavedVerse = false
                let backItem = UIBarButtonItem()
                backItem.title = "back".localized
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


