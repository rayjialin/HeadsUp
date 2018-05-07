//
//  ProfileTableView.swift
//  HeadsUp
//
//  Created by ruijia lin on 5/6/18.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import Foundation
import UIKit

class ProfileTableView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    var segueDict = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.adjustsFontSizeToFitWidth = true
        ViewLayoutConstraint.viewLayoutConstraint(backgroundImage, defaultView: self.view)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "profileCellId", for: indexPath) as? ProfileCell{
            
            if let profileName = segueDict["closestUser"]{
                cell.profileName.text = profileName
            }
            
            if let profilePhone = segueDict["closestUserPhoneNumber"]{
                cell.profilePhone.text = profilePhone
            }
            if let profileFeedback = segueDict["matchedUserFeedback"]{
                cell.profileTextView.text = profileFeedback
            }
            
            if let imageUrl = segueDict["closestUserImageUrl"] {
                MainViewController.downloadProfileImage(imageUrl: imageUrl) { (data, response, error) in
                    if let error = error {
                        print(error)
                    }
                    
                    DispatchQueue.main.async {
                        cell.profileImage.image = UIImage(data: data!)
                    }
                    
                }
            }
            
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "profileCellId", for: indexPath)
    }
    
}
