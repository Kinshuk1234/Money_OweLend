//
//  ViewController.swift
//  Money Owelend - Your personal accountant
//
//  Created by Kinshuk Singh on 2017-08-23.
//  Copyright © 2017 Ksk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var facebookLogin: FBSDKLoginButton!
    
    @IBOutlet weak var signInButtonText: UIButton!
    @IBOutlet weak var resetButtonText: UIButton!
    @IBOutlet weak var signupButtonText: UIButton!
    
    
    
    @IBAction func signupButton(_ sender: Any) {
        
        performSegue(withIdentifier: "signupViewController", sender: self)
        
    }
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
   
    @IBAction func signIn(_ sender: Any) {
        
        if self.email.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            createAlert(title: "Error", message: "Please enter an email and password.")
            
        } else {
            
            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    self.redirect()
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    
                    self.createAlert(title: "Error", message: (error?.localizedDescription)!)
                }
            }
        
    }
    }
    
    @IBAction func reset(_ sender: Any) {
        
        performSegue(withIdentifier: "resetViewController", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // rounded buttons
        signInButtonText.layer.cornerRadius = 4
        signupButtonText.layer.cornerRadius = 4
        resetButtonText.layer.cornerRadius = 4
        
        self.facebookLogin.isHidden = true
    }
    
    
    func redirect() {
        
        if Auth.auth().currentUser == nil {
            
            facebookLogin.readPermissions = ["public_profile", "email", "user_friends"]
            facebookLogin.delegate = self
            view.addSubview(facebookLogin as? UIView ?? UIView())
            
            self.facebookLogin.isHidden = false
            
        } else {
        
            let storage = Storage.storage()
            let storageRef = storage.reference(forURL: "gs://money-owelend.appspot.com")
            let uid = Auth.auth().currentUser?.uid
            let profilePhotoRef = storageRef.child(uid! + "profile_photo.jpg")
        
            profilePhotoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            
            if data != nil {
                
                self.performSegue(withIdentifier: "loginToDashboard", sender: self)
                
            } else {
                
                self.performSegue(withIdentifier: "loginToMain", sender: self)
                
            }
            
        }
    }
}
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        self.facebookLogin.isHidden = true
        
        print("user logged in")
        
        if error != nil {
            
            // handle errors here
            
            // self.facebookLoginButton.isHidden = false
            
        } else if result.isCancelled {
            
            // self.facebookLoginButton.isHidden = false
            
        } else {
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                
                self.createAlert(title: "Error", message: (error?.localizedDescription)!)
                
            } else {
                
                print("user logged in to firebase")
                
                self.ref = Database.database().reference()
                
                let currentUser = Auth.auth().currentUser
                
                let userData = ["name": currentUser?.displayName, "email": currentUser?.email, "uID": currentUser?.uid]
                
                // getting image using Facebook's Graph API
                
                let storage = Storage.storage()
                
                let storageRef = storage.reference(forURL: "gs://money-owelend.appspot.com")
                
                var profilePhoto = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height": 300, "width": 300, "redirect": false], httpMethod: "GET")
                
                profilePhoto?.start(completionHandler: {(connection, result, error) -> Void in
                    
                    if error == nil {
                        
                        let resultDict = result as? NSDictionary
                        
                        let data = resultDict?.object(forKey: "data") as? NSDictionary
                        
                        let photoURL = (data?.object(forKey: "url"))! as! String
                        
                        let uid = currentUser?.uid
                        
                        if let imageData = try? Data(contentsOf: URL(string: photoURL)!) {
                            
                            let profilePhotoRef = storageRef.child(uid! + "profile_photo.jpg")
                            
                            let uploadTask = profilePhotoRef.putData(imageData, metadata: nil) { (metadata, error) in
                                
                                if error == nil {
                                    
                                    let downloadURL = metadata?.downloadURL
                                    
                                } else {
                                    
                                    print("couldn't upload the photo")
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                })
                
                //self.ref.child("users").child(currentUser!.uid).setValue(userData)
            
                self.performSegue(withIdentifier: "loginToMain", sender: self)
                
            }
            
        }
    }
        
}
    
        
    override func viewDidAppear(_ animated: Bool) {
        
        redirect()
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("user logged out")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

