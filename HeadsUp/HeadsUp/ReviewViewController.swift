//
//  ReviewViewController.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-05.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closestUser = UserDefaults.standard.value(forKey: "CLOSEST_USER") as! String
        self.nameLabel.text = closestUser
        
        textView.delegate = self
        textView.text = "How was your conversation? Write notes to save for later."
        textView.textColor = UIColor.lightGray
        
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapped))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped() {
        self.view.endEditing(true);
    }
    
    /*
     Placeholder for text was taken from https://stackoverflow.com/questions/27652227/text-view-placeholder-swift
     */
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "How was your conversation? Write notes to save for later."
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
