//
//  NameDetailViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class NameDetailViewController: UIViewController {
    
    @IBOutlet weak var nameTextView: UITextView!
    
    var name = Name()
    var languageId = 0
    var tranlationId = 0
    var searchString = ""
    
    private let dataBase = DataBase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = name.nameText
        
        let showName = dataBase.getNameHtml(nameId: name.nameId, languageId: languageId)
        
        nameTextView.attributedText = "<div style=\"font-size:18px; margin-left:5px\"><b>\(name.nameDescription)</b><br/><br/>\(showName)</div>".htmlToAttributedString
    }
    
}


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
