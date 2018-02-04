//
//  FriendsListViewController.swift
//  Money Owelend - Your personal accountant
//
//  Created by Kinshuk Singh on 2017-08-26.
//  Copyright © 2017 Ksk. All rights reserved.
//

import UIKit
import Firebase

class FriendsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference!
    
    var refresher: UIRefreshControl!
    
    var refHandle: UInt!
    
    var userImages = [UIImage]()
    var userIDs = [String]()
    var userNames = [String]()

    @IBAction func back(_ sender: Any) {
        
        performSegue(withIdentifier: "friendListToAddFriends", sender: self)
        
    }
    
    @IBOutlet weak var friendListTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        friendListFunc()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(FriendsListViewController.friendListFunc), for: UIControlEvents.valueChanged)
        friendListTable.addSubview(refresher)
        
    }
    
    func friendListFunc() {
        
        ref = Database.database().reference()
        
        let currentUserID = Auth.auth().currentUser?.uid
        
        refHandle = ref.child("users").child(currentUserID!).observe(.value, with: { (snapshot) in
            
            if let userDict = snapshot.value as? [String: Any] {

                if let friends = userDict["friends"] as? [String: Any] {
                    
                    self.userIDs.removeAll()
                    self.userNames.removeAll()
                    self.userImages.removeAll()
 
                    for friend in friends {
                       
                        self.refHandle = self.ref.child("users").child(friend.key).observe(.value, with: { (snapshot) in
                            
                            if let userDict = snapshot.value as? [String: Any] {
                                
                                if let userName = userDict["name"] {
                                    
                                    let storage = Storage.storage()
                                    
                                    let storageRef = storage.reference(forURL: "gs://money-owelend.appspot.com")
                                    
                                    let profilePhotoRef = storageRef.child(friend.key + "profile_photo.jpg")
                                    
                                    profilePhotoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                        
                                        if let error = error {
                                            
                                            print("couldn't download the image")
                                            
                                        } else {
                                            
                                            self.userNames.append(userName as! String)
                                            self.userIDs.append(friend.key)
                                            self.userImages.append(UIImage(data: data!)!)
                                            
                                            //
                                            self.friendListTable.reloadData()
                                            self.ref.removeAllObservers()
                                            self.refresher.endRefreshing()
                                            
                                        }
                                    }
                                }
                            }
                        }, withCancel: { (error) in
                            
                            print("error observing value \(error)")
                            
                        })
                    }
                }
            }
        }, withCancel: { (error) in
            
            print("error observing value \(error)")
            
        })
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userIDs.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFriendList", for: indexPath) as! FriendListTableViewCell
        
        cell.userName.text = userNames[indexPath.row]
        
        cell.userImage.image = userImages[indexPath.row]
        
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
