//
//  MainViewController.swift
//  Money Owelend - Your personal accountant
//
//  Created by Kinshuk Singh on 2017-08-24.
//  Copyright © 2017 Ksk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit

class MainViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var ref: DatabaseReference!
    var refHandle: UInt!
    
    
    var activityIndicator = UIActivityIndicatorView()
    
    // Logout

    @IBAction func logout(_ sender: Any) {
        
        // log the user out from firebase app
        
        try! Auth.auth().signOut()
        
        // log the user out from facebook tokken
        
        FBSDKAccessToken.setCurrent(nil)
        
        // after that move the user back to login screen
        
        performSegue(withIdentifier: "mainToLogin", sender: self)
        
    }
    
    // Update welcome label with user's name
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    // Choose Image File
    
    @IBAction func chooseFileButton(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.image.image = image
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var uploadButtonText: UIButton!
    
    
    // Finally upload file to the Firebase Storage
    
    @IBAction func uploadButton(_ sender: Any) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let storage = Storage.storage()
        
        let storageRef = storage.reference(forURL: "gs://money-owelend.appspot.com")
        
        let uid = Auth.auth().currentUser?.uid
        
        let profilePhotoRef = storageRef.child(uid! + "profile_photo.jpg")
        
        profilePhotoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            
            if data != nil {
            
                // delete old photo
                
                profilePhotoRef.delete { error in
                    
                    if let error = error {
                        
                        print("couldn't delete the old photo")
                        
                    } else {
                        
                        print("successfully deleted")
                        
                    }
                }
                
                // then upload new photo
                
                let imageFile = self.image.image
                
                let imageData: Data = UIImageJPEGRepresentation(imageFile!, 0.0)!
                
                let uploadTask = profilePhotoRef.putData(imageData, metadata: nil) { (metadata, error) in
                    
                    if error == nil {
                        
                        self.performSegue(withIdentifier: "mainToDashboard", sender: self)
                        
                        let downloadURL = metadata?.downloadURL
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        print("user headed to dashboard")
                        
                    } else {
                    
                        print("couldn't upload the image")
                        
                    }
                }
                
            } else {
                
                // just upload the new file
            
                let imageFile = self.image.image
                
                let imageData: Data = UIImageJPEGRepresentation(imageFile!, 0.0)!
                
                let uploadTask = profilePhotoRef.putData(imageData, metadata: nil) { (metadata, error) in
                    
                    if error == nil {
                        
                         self.performSegue(withIdentifier: "mainToDashboard", sender: self)
                        
                        let downloadURL = metadata?.downloadURL
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        print("user headed to dashboard")
                        
                    } else {
                        
                        print("couldn't upload the image")
                        
                    }
                }
                
            }
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        uploadButtonText.layer.cornerRadius = 4
        
        // retrieving data from database
        
        ref = Database.database().reference()
        
        // specific data
        
        if let user = Auth.auth().currentUser {
            
            let userID = user.uid
            
            // user's name
            
            ref = Database.database().reference()
            
            refHandle = ref.child("users").child(userID).observe(.value, with: { (snapshot) in
                
                print("we got a value \(snapshot)")
                
                print(snapshot)
                
                if let userDict = snapshot.value as? [String: Any] {
                let name = userDict["name"] as! String
                
                self.welcomeLabel.text = "Welcome, \(name)!"
                    
                }
                
            }, withCancel: { (error) in
                
                print("error observing value \(error)")
                
            })
            
            // user's photo
            
            let storage = Storage.storage()
            
            let storageRef = storage.reference(forURL: "gs://money-owelend.appspot.com")
            
            let uid = Auth.auth().currentUser?.uid
            
            let profilePhotoRef = storageRef.child(uid! + "profile_photo.jpg")
            
            profilePhotoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                
                if let error = error {
                    
                    print("couldn't download the image")
                    
                } else {
                    
                    self.image.image = UIImage(data: data!)
                    
                }
            }
            
        }
            
        else {
            
            print("could not find user")
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}




















