//
//  CreateUserProfile.swift
//  HeadsUp
//
//  Created by ruijia lin on 5/6/18.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import Foundation

var image: UIImage? = UIImage()
var name = String()
var email = String()
var phoneNumber = String()

//func updateDistanceLabels(label: UILabel, managerLocation: CLLocationCoordinate2D, closestUser: User) {
//    if managerLocation.distance(from: closestUser.coordinate) >= 1000 {
//        label.text = String(format: "%.0f km", managerLocation.distance(from: closestUser.coordinate) / 1000)
//    } else {
//        label.text =  String(format: "%.0f m", managerLocation.distance(from: closestUser.coordinate))
//    }
//}
//
//func createUserProfile(){
//    if let uuid = UserDefaults.standard.value(forKey: "MY_UUID") as? String {
//        if uuid == "5A88BD2B-B18D-46C4-9CBA-628C738ED874" || uuid == "849A01AA-2F57-4438-BAAA-70B7F2FAB975"{
//            image = #imageLiteral(resourceName: "brian")
//            name = "Brian"
//            email = "brianLHL@gmail.com"
//            phoneNumber = "123-456-1234"
//        }else if uuid == "C86474A7-DE27-4B1B-A5BF-186FDF648622" || uuid == "4CFFA45B-BBB8-4E7C-99D6-FA453669C269"{
//            image = #imageLiteral(resourceName: "ray")
//            name = "Ray"
//            email = "rayLHL@gmail.com"
//            phoneNumber = "999-999-9999"
//        }
//        guard let image = image else {return}
//        let imageName = NSUUID().uuidString
//        let storageRef = Storage.storage().reference().child("\(imageName).png")
//
//        if let uploadData = UIImagePNGRepresentation(image){
//            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
//                if let error = error{
//                    print(error)
//                    return
//                }
//
//                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
//                    self.user?.profileImageUrl = profileImageUrl
//                    self.user?.name = self.name
//                    self.user?.email = self.email
//                    self.user?.phoneNumber = self.phoneNumber
//
//                    UserDefaults.standard.set(profileImageUrl, forKey: "ProfileimageUrl")
//                    UserDefaults.standard.set(self.email, forKey: "email")
//                    UserDefaults.standard.set(self.phoneNumber, forKey: "phoneNumber")
//                    UserDefaults.standard.set(self.name, forKey: "name")
//
//                    let userRef = Database.database().reference().child("Users").child(uuid)
//                    userRef.updateChildValues(["name": self.user?.name])
//                    userRef.updateChildValues(["email": self.user?.email])
//                    userRef.updateChildValues(["profileImage": self.user?.profileImageUrl])
//                    userRef.updateChildValues(["phoneNumber": self.user?.phoneNumber])
//                }
//            }
//        }
//    }
//}
//
//class func downloadProfileImage(imageUrl: String, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//    guard let url = URL(string: imageUrl) else {return}
//    URLSession.shared.dataTask(with: url) { data, response, error in
//        completion(data, response, error)
//        }.resume()
//}
