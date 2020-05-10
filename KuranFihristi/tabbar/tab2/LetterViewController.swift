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
    private var funcs = Functions()
    private var searchString = ""
    
    private var languageId = 1
    private var translationId = 154
    private var fontSize = 17

    let labelInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0)
    
    
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
                self.fullLetters = self.dataBase.getLettersWords(languageId: self.languageId, searchText: "")
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
        
        fullLetters = dataBase.getLettersWords(languageId: languageId, searchText: "") //dataBase.getLetters(languageId: languageId)
        letters = fullLetters
        
//        let ls = dataBase.getLettersWords(languageId: 1)
//
//        for l in ls {
//            for w in l.words {
//                print("\(l.letterName) - \(w.wordName)")
//            }
//        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.title = "dictionary".localized
        
        prepareSearchController()
        tableView.tableFooterView = UIView()
//        tableView.sectionIndexColor = .systemRed
//        tableView.sectionHeaderHeight = CGFloat(50)
        tableView.sectionIndexBackgroundColor = UIColor.clear
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
//        fullSearchButton.removeFromSuperview()
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
            letters = dataBase.getLettersWords(languageId: languageId, searchText: searchText)
        } else {
            letters = fullLetters
        }
        

         if searchText.count > 2 {
            let l = Letter(letterId: 0, letterName: "")
            l.words.append(Word(wordId: 0, wordName: ""))
            letters.insert(l, at: 0)
         } else {
            letters.removeAll { (Letter) -> Bool in
                Letter.letterId == 0
            }
         }
        
        tableView.reloadData()
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        searchController.searchBar.endEditing(true)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return letters.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return letters[section].words.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        " - \(letters[section].letterName)"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = .systemFont(ofSize: CGFloat(fontSize-1))//UIFont(name: "Futura", size: 12) // change it according to ur requirement
        header?.textLabel?.textColor = .systemGray // change it according to ur requirement
    }
    
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
        return letters.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var headers = Array<String>()
        for l in letters {
            headers.append(l.letterName)
        }
        return headers
    }
    
//    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
//        return -1
//    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        let label : UILabel = UILabel()
//        label.text = " - \(letters[section].letterName)"//letters[section].letterName
//        label.font = .systemFont(ofSize: CGFloat(fontSize))
//        view.frame.inset(by: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
//        view.addSubview(label)
////        label.frame.offsetBy(dx: 50, dy: 10)
//        return view
//    }
    
//    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat(50)
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let letterItem = letters[indexPath.section]
        let wordItem = letterItem.words[indexPath.row]
        if letterItem.letterId == 0 {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFullViewCell", for: indexPath as IndexPath) as! SearchFullViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "letterItemViewCell", for: indexPath as IndexPath) as! ItemViewCell
            cell.nameLabel.text = " \(wordItem.wordName)"
            cell.nameLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let letterItem = letters[indexPath.section]
        let wordItem = letterItem.words[indexPath.row]
        if letterItem.letterId == 0 {
            SwiftEventBus.post("goToSearch", sender: self.searchString)
        } else {
            let letterWord = LetterWord(letter: letterItem, word: wordItem)
            performSegue(withIdentifier: "showVerseByWord", sender: letterWord)
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
        if segue.identifier == "showVerseByWord" {
            if let verseByWordController = segue.destination as? VerseByWordViewController {
                let selectedLetterWord = sender as! LetterWord
                verseByWordController.fontSize = fontSize
                verseByWordController.word = selectedLetterWord.word
                verseByWordController.letter = selectedLetterWord.letter
                verseByWordController.languageId = languageId
                verseByWordController.translationId = translationId
//                wordController.letter = selectedLetterWord.letter
//                wordController.languageId = languageId
//                wordController.fontSize = fontSize
//                wordController.translationId = translationId
                let backItem = UIBarButtonItem()
                backItem.title = "back".localized
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
}
