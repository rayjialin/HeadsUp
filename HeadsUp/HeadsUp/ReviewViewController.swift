//
//  ReviewViewController.swift
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-05.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class ReviewViewController: UIViewController, UITextViewDelegate {
    
//    var segueDict = [String:String]
    
    var user: User?
    var matchedUserUUID: String?
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var matchedUserImage: UIImageView!
    @IBOutlet weak var matchedUserPhoneNumber: UILabel!
    let geofireRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start observing phone number
        obseringPhoneNumber()
        
        if let matchedUUID = UserDefaults.standard.value(forKey: "closestUserUUID") as? String{
            matchedUserUUID = matchedUUID
        }
        
        if let closestUser = UserDefaults.standard.value(forKey: "CLOSEST_USER") as? String {
            self.nameLabel.text = closestUser
        }
        
        if let closestUserImageUrl = UserDefaults.standard.value(forKey: "closestUserImageUrl") as? String {
            let imageUrl = closestUserImageUrl
            
            MainViewController.downloadProfileImage(imageUrl: imageUrl, completion: { (data, response, error) in
                if let error = error{
                    print(error)
                }
                DispatchQueue.main.async {
                    self.matchedUserImage.image = UIImage(data: data!)
                    self.matchedUserImage.layer.cornerRadius = self.matchedUserImage.frame.size.width / 2
                    self.matchedUserImage.contentMode = .scaleAspectFit
                }
                
            })
        }
        
        
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
    
    
    @IBAction func showPhoneNumber(_ sender: UIButton) {
        guard let uuid = UserDefaults.standard.value(forKey: "MY_UUID") as? String else {return}
        geofireRef.child("Users").child(uuid).updateChildValues(["showPhoneNumber": true])
    }
    
    
    func obseringPhoneNumber(){
        geofireRef.child("Users").observe(.value, with: { (snapshot) in
            guard let uuid = self.matchedUserUUID else {return}
            guard let showPhoneNumber = snapshot.childSnapshot(forPath: uuid).childSnapshot(forPath: "showPhoneNumber").value as? Bool else {return}
            
            if showPhoneNumber == true{
                UIView.animate(withDuration: 3, delay: 0, options: .curveEaseIn, animations: {
                    let closestUserPhoneNumber = UserDefaults.standard.value(forKey: "closestUserPhoneNumber") as? String
                    self.matchedUserPhoneNumber.text = closestUserPhoneNumber
                }, completion: nil)
            }
        })
    }
    

    @IBAction func segueToTV(_ sender: UIButton) {
//        performSegue(withIdentifier: "segueToTVId", sender: self)
        print("naything")
    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        <#code#>
//    }
}
