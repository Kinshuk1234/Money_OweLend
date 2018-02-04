//
//  AddFriendsViewController.swift
//  Money Owelend - Your personal accountant
//
//  Created by Kinshuk Singh on 2017-08-26.
//  Copyright © 2017 Ksk. All rights reserved.
//

import UIKit
import Darwin
import Firebase

class AddFriendsViewController: UIViewController {
    
    var shouldBeSend: Bool = true
    
    @IBOutlet weak var sendButtonText: UIButton!
    
    @IBAction func friendList(_ sender: Any) {
        
        performSegue(withIdentifier: "addFriendsToFriendList", sender: self)
        
    }
    
    @IBAction func sent(_ sender: Any) {
        
        performSegue(withIdentifier: "addFriendsToSent", sender: self)
        
    }
    
    @IBAction func received(_ sender: Any) {
        
        performSegue(withIdentifier: "addFriendsToReceived", sender: self)
        
    }
   
    
    @IBAction func back(_ sender: Any) {
        
        performSegue(withIdentifier: "addFriendToDashboard", sender: self)
        
    }
    
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    var ref: DatabaseReference!
    
    var friendUserID: String = ""
    
    @IBOutlet weak var friendsEmailText: UITextField!
    
    
    @IBAction func sendRequest(_ sender: Any) {
        
        if friendsEmailText.text == "" {
            
            createAlert(title: "Oops!", message: "Please enter an email.")
            
        } else {
            
            ref = Database.database().reference()
            
            let userRef = ref.child("users")
            
            let emailQuery = userRef.queryOrdered(byChild: "email").queryEqual(toValue: friendsEmailText.text)
            
            emailQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.value is NSNull) {
                    
                    self.createAlert(title: "Error", message: "No user exists with the entered email")
                    
                } else if Auth.auth().currentUser?.email == self.friendsEmailText.text {
                    
                    self.createAlert(title: "Error", message: "Unfortunately! You have entered your own email")
                    
                } else {
                    
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let uID = userSnap.key
                        self.friendUserID = uID
                    }
                    
                    let currentUserID = Auth.auth().currentUser?.uid
                    
                    // check if the current user has already sent a request or the user has already sent a request to current user
                    
                    _ = self.ref.child("users").child(currentUserID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        // checking for sent or received requests
                        if let userDict = snapshot.value as? [String: Any] {
                            
                            if let requests = userDict["requests"] as? [String: String] {
                                
                                for request in requests {
                                    
                                    if request.key == self.friendUserID {
                                        
                                        self.shouldBeSend = false
                                        self.createAlert(title: "Error", message: "Either you have already sent or received a request from this user")
                                        return
                                        
                                    }
                                }
                            }
                            
                            // checking for already being friends
                            if let friends = userDict["friends"] as? [String: Any] {
                                
                                for friend in friends {
                                    
                                    if friend.key == self.friendUserID {
                                        
                                        self.shouldBeSend = false
                                        self.createAlert(title: "Error", message: "You're already friends with this user")
                                        return
                                        
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async {
                                
                                if self.shouldBeSend == true {
                                    
                                    print("request successfult sent")
                                    
                                    // sending requests now
                                    
                                    // adding the request as sent at sender's requests:
                                    let existsCheckCurrentUserRef = self.ref.child("users").child(currentUserID!)
                                    
                                    existsCheckCurrentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                        
                                        if snapshot.hasChild("requests"){
                                            
                                            self.ref.child("users").child(currentUserID!).child("requests").updateChildValues([self.friendUserID: "sent"])
                                            
                                        } else{
                                            
                                            self.ref.child("users").child(currentUserID!).child("requests").setValue([self.friendUserID: "sent"])
                                        }
                                        
                                        print("saved sent request")
                                        
                                    })
                                    
                                    // adding the request as received at receiver's requests:
                                    
                                    let existsCheckFriendUserRef = self.ref.child("users").child(self.friendUserID)
                                    
                                    existsCheckFriendUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                        
                                        if snapshot.hasChild("requests"){
                                            
                                            self.ref.child("users").child(self.friendUserID).child("requests").updateChildValues([currentUserID!: "received"])
                                            
                                        } else{
                                            
                                            self.ref.child("users").child(self.friendUserID).child("requests").setValue([currentUserID!: "received"])
                                        }
                                        
                                        print("saved received request")
                                        
                                    })
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButtonText.layer.cornerRadius = 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
