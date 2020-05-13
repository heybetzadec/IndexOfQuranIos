//
//  TextImegeViewController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/12/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class TextImegeViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var text = ""
    var languageId = 0
    var translationId = 154
    var darkMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fileURL = Bundle.main.path(forResource: "texture1", ofType: "png", inDirectory: "Documents")
      
        let imageFromPath = UIImage(contentsOfFile: fileURL!)!
        
        let image = self.textToImage(drawText: text, inImage: imageFromPath, atPoint: CGPoint(x: 10, y: 50))

        imageView.image = image
        
        let view1 = UIView()
        let view2 = UIView()
        
        view1.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        view1.backgroundColor = .red
        
        
        view2.frame = CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        view2.backgroundColor = .blue
        
        scrollView.addSubview(view1)
        scrollView.addSubview(view2)
        
        
    }
    
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 17)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
//        textView.attributedText = NSAttributedString(string: "String",  attributes: [.paragraphStyle: paragraph])

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraph
            ] as [NSAttributedString.Key : Any]
        
//        let attributedText = "<h1>A</h1>".htmlToAttributedString
//        attributedText?.draw(in: rect)
        
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
}
