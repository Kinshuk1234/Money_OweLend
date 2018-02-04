//
//  AddEntryViewController.swift
//  Money Owelend - Your personal accountant
//
//  Created by Kinshuk Singh on 2017-09-01.
//  Copyright © 2017 Ksk. All rights reserved.
//

import UIKit
import Firebase

class AddEntryViewController: UIViewController {
    
    var ref: DatabaseReference!
    let currentUserID = Auth.auth().currentUser?.uid
    let currentUserName = Auth.auth().currentUser?.displayName
    var selectedFriendID = ""
    var selectedFriendName = ""
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    let datePicker = UIDatePicker()
   
    @IBOutlet weak var descriptiontext: UITextField!
    
    @IBOutlet weak var dateText: UITextField!
    
    @IBOutlet weak var additionalText: UITextField!
    
    @IBAction func sentButton(_ sender: Any) {
        
        if descriptiontext.text == "" || dateText.text == "" {
        
            createAlert(title: "Error", message: "Please fill the mandatory fields.")
            
        } else {
        
            let userData = ["name": currentUserName, "description": descriptiontext.text, "date": dateText.text, "additional": additionalText.text]
            
            
            
            
            
            /*let currentUserID = Auth.auth().currentUser?.uid
             
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
             
             })*/
            
        }
        
        
        
    }
    
    func pickDate() {
        
        datePicker.datePickerMode = .date
    
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        dateText.inputAccessoryView = toolbar
        dateText.inputView = datePicker
        
    }
    
    func donePressed() {
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        dateText.text = dateFormatter.string(for: datePicker.date)
        self.view.endEditing(true)
        
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        performSegue(withIdentifier: "addEntryToDashboard", sender: self)
        
    }
    
    var friendsIDs = [String]()
    var friendsNames = [String]()
    
    @IBOutlet weak var DDbuttontext: UIButton!
    
    @IBAction func DDButton(_ sender: Any) {
        
        self.tableView.isHidden = !self.tableView.isHidden
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickDate()
        
        tableView.isHidden = true
        getFriendList()
    
    }
    
    func getFriendList() {
        
        friendsIDs.removeAll()
        friendsNames.removeAll()
        
        ref = Database.database().reference()
        
        _ = ref.child("users").child(currentUserID!).observe(.value, with: { (snapshot) in
            
            if let userDict = snapshot.value as? [String: Any] {
            
                if let friends = userDict["friends"] as? [String: Any] {
                
                    for friend in friends {
                        
                        _ = self.ref.child("users").child(friend.key).observe(.value, with: { (snapshot) in
                            
                            if let userDict = snapshot.value as? [String: Any] {
                                
                                if let userName = userDict["name"] {
                                    
                                    self.friendsIDs.append(friend.key)
                                    self.friendsNames.append(userName as! String)
                                    self.tableView.reloadData()
                                    self.ref.removeAllObservers()
                                    
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension AddEntryViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friendsIDs.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CellDD")
        
        cell.textLabel?.text = friendsNames[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        selectedFriendID = friendsIDs[indexPath.row]
        selectedFriendName = friendsNames[indexPath.row]
        
        // print
        print(selectedFriendID)
        
        DDbuttontext.setTitle(cell?.textLabel?.text, for: [])
        
        self.tableView.isHidden = true
    }
}































