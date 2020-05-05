//
//  VerseDetailViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/1/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class VerseDetailViewController: UITableViewController {
    
    
    var chapterName = ""
    var chapterId = 0
    var verseId = 0
    var languageId = 0
    var tranlationId = 0
    
    var bottomItems =  Array<BottomItem>()
    var attributedString = NSMutableAttributedString()
    var verseText = ""
    
    
    private let dataBase = DataBase()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let verseName = "\(chapterId). \(chapterName), \(verseId)"
        navigationItem.title = verseName
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        let verse = dataBase.getVerse(chapterId: chapterId, verseId: verseId, tranlationId: tranlationId)
        let verseLatin = dataBase.getVerse(chapterId: chapterId, verseId: verseId, tranlationId: 9)
        let verseOriginal = dataBase.getVerse(chapterId: chapterId, verseId: verseId, tranlationId: 1)
        
        verseText = "\(verse.verseText)\n\(verseName)"
        
        let attrsBold = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]
        let attrsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)]
        
        var boldText = "Seçili meal\n"
        var boldString = NSMutableAttributedString(string:boldText, attributes:attrsBold)
        var normalString = NSMutableAttributedString(string:verse.verseText, attributes:attrsNormal)
        attributedString = boldString
        attributedString.append(normalString)
        
        boldText = "\n\nLatin alfabesi\n"
        boldString = NSMutableAttributedString(string:boldText, attributes:attrsBold)
        normalString = NSMutableAttributedString(string:verseLatin.verseText, attributes:attrsNormal)
        attributedString.append(boldString)
        attributedString.append(normalString)
        
        
        boldText = "\n\nArapça\n"
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        let attrsArabicNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22),
                                 NSAttributedString.Key.paragraphStyle: paragraph]
        boldString = NSMutableAttributedString(string:boldText, attributes:attrsBold)
        normalString = NSMutableAttributedString(string:verseOriginal.verseText, attributes:attrsArabicNormal)
        attributedString.append(boldString)
        attributedString.append(normalString)
        
        
        bottomItems.append(BottomItem(id: 0, name: "", icon: "add"))
        bottomItems.append(BottomItem(id: 1, name: "Ayeti Paylaş", icon: "square.and.arrow.up"))
        bottomItems.append(BottomItem(id: 2, name: "Ayeti Kopyala", icon: "doc.on.doc"))
        bottomItems.append(BottomItem(id: 3, name: "Ayeti Pinle", icon: "pin"))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bottomItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "verseDetailViewCell", for: indexPath as IndexPath) as! VerseDetailViewCell
            cell.textView.attributedText = attributedString
            cell.textView.textColor = UIColor.label
            return cell
        } else {
            let bottomItem = bottomItems[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "bottomViewCell", for: indexPath as IndexPath) as! BottomViewCell
            cell.labelText.text = bottomItem.name
            cell.iconView.image =  UIImage(systemName: bottomItem.icon) ?? .add
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 1:
            let textShare = [ verseText ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        case 2:
            UIPasteboard.general.string = verseText
            showToast(message: "Kopyalandı")
        case 3:
            dataBase.insertSavedVerse(verses: [Verse(chapterId: chapterId, verseId: verseId, verseText: "")])
            showToast(message: "Pinlendi")
        default: break
        }
    }
    
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.tableView.contentSize.height - 150 , width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
