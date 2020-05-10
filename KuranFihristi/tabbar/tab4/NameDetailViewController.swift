//
//  NameDetailViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit
import SwiftEventBus

class NameDetailViewController: UIViewController {
    
    @IBOutlet weak var nameTextView: UITextView!
    
    var name = Name()
    var languageId = 1
    var translationId = 154
    var fontSize = 17
    
    private let dataBase = DataBase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name:"optionChange") { result in
            let option = result?.object as! Option
            
            if option.languageId != self.languageId {
                self.languageId = option.languageId
                self.load()
            }
            
            if self.fontSize != option.fontSize {
                self.fontSize = option.fontSize
                self.load()
            }
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = name.nameText
        
        load()
        nameTextView.textColor = UIColor.label
    }
    
    func load(){
        let showName = dataBase.getNameHtml(nameId: name.nameId, languageId: languageId)
        
        nameTextView.attributedText = "<div style=\"font-size:\(fontSize+1)px;\"><b>\(name.nameDescription)</b><br/><br/>\(showName)<br/><br/></div>".htmlToAttributedString
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
