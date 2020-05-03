//
//  VerseDetailViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class VerseDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    
    var chapterName = ""
    var chapterId = 0
    var verseId = 0
    var languageId = 0
    var tranlationId = 0
    
    var bottomItems =  Array<BottomItem>()
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        
        navigationItem.title = "\(chapterId). \(chapterName), \(verseId)"
        
        
        bottomItems.append(BottomItem(id: 1, name: "Ayeti Paylaş", icon: UIImage(systemName: "square.and.arrow.up") ?? .add))
        bottomItems.append(BottomItem(id: 1, name: "Ayeti Kopyala", icon: UIImage(systemName: "doc.on.doc") ?? .add))
        bottomItems.append(BottomItem(id: 1, name: "Ayeti Pinle", icon: UIImage(systemName: "pin") ?? .add))

        tableView.delegate = self
        tableView.dataSource = self
        
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.scrollsToTop = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bottomItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bottomItem = bottomItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "bottomViewCell", for: indexPath as IndexPath) as! BottomViewCell
        cell.labelText.text = bottomItem.name
        cell.iconView.image = bottomItem.icon
        
        return cell
    }

}
