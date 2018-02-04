//
//  SignUpViewController.swift
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

class SignUpViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var ref: DatabaseReference!
    
    
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    @IBOutlet weak var signupButtonText: UIButton!
    
    @IBOutlet weak var loginButtonText: UIButton!
    
   
    @IBAction func loginButton(_ sender: Any) {
        
        performSegue(withIdentifier: "loginViewController", sender: self)
        
    }
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBAction func signup(_ sender: Any) {
        
        if name.text == "" || email.text == "" || password.text == "" || confirmPassword.text == "" {
            
            createAlert(title: "Error", message: "Some detailes are missing")
            
        } else if password.text != confirmPassword.text {
            
            createAlert(title: "Error", message: "Passwords don't match")
            
        } else {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
                
                if error == nil {
                    
                     //Successfully authenticated user
                    
                    self.ref = Database.database().reference()
                    
                    let userData = ["name": self.name.text, "email": self.email.text, "uID": user?.uid]
                    
                    self.ref.child("users").child(user!.uid).setValue(userData)
        
                    print("You have successfully signed up")
                    
                    self.performSegue(withIdentifier: "signupToMain", sender: self)
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    
                    //let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    //self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    self.createAlert(title: "Error", message: (error?.localizedDescription)!)
                }
            }
        
    }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        signupButtonText.layer.cornerRadius = 4
        loginButtonText.layer.cornerRadius = 4
        
        self.facebookLoginButton.isHidden = true
        
        if Auth.auth().currentUser != nil {
            
            // User is signed in.
            // move the user to home screen
            
            performSegue(withIdentifier: "signupToMain", sender: self)
            
        } else {
            
            // No user is signed in.
            // move the user to login screen
            
            facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
            facebookLoginButton.delegate = self
            view.addSubview(facebookLoginButton as? UIView ?? UIView())
            
            self.facebookLoginButton.isHidden = false
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser != nil {
        
            performSegue(withIdentifier: "signupToMain", sender: self)
        
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        print("user logged in")
        
        self.facebookLoginButton.isHidden = true
        
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
            
                        self.ref.child("users").child(currentUser!.uid).setValue(userData)
                        self.performSegue(withIdentifier: "signupToMain", sender: self)
            
                    }
                }
            }
        }

    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("user logged out")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}
