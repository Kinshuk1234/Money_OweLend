//
//  ReceivedViewController.swift
//  Money Owelend - Your personal accountant
//
//  Created by Kinshuk Singh on 2017-08-26.
//  Copyright © 2017 Ksk. All rights reserved.
//

import UIKit
import Firebase

class ReceivedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var receivedTable: UITableView!
    
    var userImages = [UIImage]()
    var userIDs = [String]()
    var userNames = [String]()
    
    var ref: DatabaseReference!
    var refresher: UIRefreshControl!
    
    
    @IBAction func back(_ sender: Any) {
        
        performSegue(withIdentifier: "receivedToAddFriends", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        receivedFunc()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ReceivedViewController.receivedFunc), for: UIControlEvents.valueChanged)
        receivedTable.addSubview(refresher)
        
    }
    
    func receivedFunc() {
        
        ref = Database.database().reference()
        
        let currentUserID = Auth.auth().currentUser?.uid
        
        _ = ref.child("users").child(currentUserID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userDict = snapshot.value as? [String: Any] {
                
                if let requests = userDict["requests"] as? [String: String] {
                    
                    print("processing received requests")
                    
                    self.userIDs.removeAll()
                    self.userNames.removeAll()
                    self.userImages.removeAll()
                    
                    for request in requests {
                        
                        if request.value == "received" {
                            
                            _ = self.ref.child("users").child(request.key).observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                if let userDict = snapshot.value as? [String: Any] {
                                    
                                    if let userName = userDict["name"] {
                                        
                                        let storage = Storage.storage()
                                        
                                        let storageRef = storage.reference(forURL: "gs://money-owelend.appspot.com")
                                        
                                        let profilePhotoRef = storageRef.child(request.key + "profile_photo.jpg")
                                        
                                        profilePhotoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                            
                                            if let error = error {
                                                
                                                print("couldn't download the image")
                                                
                                            } else {
                                                
                                                self.userNames.append(userName as! String)
                                                self.userIDs.append(request.key)
                                                self.userImages.append(UIImage(data: data!)!)
                                                
                                                //
                                                self.receivedTable.reloadData()
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
            }
        }, withCancel: { (error) in
            
            print("error observing value \(error)")
            
        })
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userIDs.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellReceived", for: indexPath) as! ReceivedTableViewCell
        
        cell.hiddenIDLabel.text = userIDs[indexPath.row]
        
        cell.userName.text = userNames[indexPath.row]
        
        cell.userImage.image = userImages[indexPath.row]
        
        cell.delegate = self
        
        cell.acceptButtonText.tag = indexPath.row
        
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// extension -- cell!

extension ReceivedViewController: ReceivedTableCellDelegate {

    func acceptButtonTapped(senderID: String, senderTag: Int) {
    
        // add the user to current user's friend list
        // remove this request from user's received requests
        
        ref = Database.database().reference()
        
        let currentUserID = Auth.auth().currentUser?.uid
        
        let currentUserRef = ref.child("users").child(currentUserID!)
        
        currentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild("friends"){
                
                self.ref.child("users").child(currentUserID!).child("friends").updateChildValues([senderID: "true"])
                
                self.ref.child("users").child(currentUserID!).child("requests").child(senderID).removeValue()
                
            } else{
                
                self.ref.child("users").child(currentUserID!).child("friends").setValue([senderID: "true"])
                
                self.ref.child("users").child(currentUserID!).child("requests").child(senderID).removeValue()
            }
            
            print("user successfully added as a friend to current user's list")
            
        })
        
        // add the current user to the user's friend list
        // remove this request from sender's sent requests
        
        let senderRef = ref.child("users").child(senderID)
        
        senderRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild("friends"){
                
                self.ref.child("users").child(senderID).child("friends").updateChildValues([currentUserID!: "true"])
                
                self.ref.child("users").child(senderID).child("requests").child(currentUserID!).removeValue()
                
            } else{
                
                self.ref.child("users").child(senderID).child("friends").setValue([currentUserID!: "true"])
                
                self.ref.child("users").child(senderID).child("requests").child(currentUserID!).removeValue()
            }
            
            print("user successfully added as a friend to sender's list")
            
        })
        
        ref.removeAllObservers()
        
        // remove row from tableview with animation
        
        let deleteIndexPaths: [Any] = [IndexPath(row: senderTag, section: 0)]
        userIDs.remove(at: senderTag)
        userNames.remove(at: senderTag)
        userImages.remove(at: senderTag)
        //receivedTable.beginUpdates()
        receivedTable.deleteRows(at: deleteIndexPaths as! [IndexPath], with: .middle)
        //receivedFunc()
        //receivedTable.endUpdates()
        //receivedTable.reloadData()
        
    }
    
    func declineButtonTapped(senderID: String, senderTag: Int) {
    
        ref = Database.database().reference()
        
        let currentUserID = Auth.auth().currentUser?.uid
        
        // remove this request from user's received requests
        
        let currentUserDeleteRef = ref.child("users").child(currentUserID!)
        
        currentUserDeleteRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.ref.child("users").child(currentUserID!).child("requests").child(senderID).removeValue()
            
        })
        
        // remove this request from sender's sent requests
        
        let senderDeleteRef = ref.child("users").child(senderID)
        
        senderDeleteRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.ref.child("users").child(senderID).child("requests").child(currentUserID!).removeValue()
            
        })
        
        ref.removeAllObservers()
        
        let deleteIndexPaths: [Any] = [IndexPath(row: senderTag, section: 0)]
        userIDs.remove(at: senderTag)
        userNames.remove(at: senderTag)
        userImages.remove(at: senderTag)
        //receivedTable.beginUpdates()
        receivedTable.deleteRows(at: deleteIndexPaths as! [IndexPath], with: .middle)
        //receivedFunc()
        //receivedTable.endUpdates()
        //receivedTable.reloadData()
        
    }
    
}










































