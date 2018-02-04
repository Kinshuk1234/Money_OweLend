//
//  DashboardViewController.swift
//  Money Owelend - Your personal accountant
//
//  Created by Kinshuk Singh on 2017-08-25.
//  Copyright © 2017 Ksk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBAction func addFriends(_ sender: Any) {
        
        performSegue(withIdentifier: "DashboardToAddFriends", sender: self)
        
    }
    
    @IBAction func addEntry(_ sender: Any) {
        
        performSegue(withIdentifier: "dashboardToAddEntry", sender: self)
        
    }
    
    
    
    @IBAction func logout(_ sender: Any) {
        
        // log the user out from firebase app
        
        try! Auth.auth().signOut()
        
        // log the user out from facebook tokken
        
        FBSDKAccessToken.setCurrent(nil)
        
        // after that move the user back to login screen
        
        performSegue(withIdentifier: "DashboardToLogin", sender: self)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return 4
        
    }
 
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CellDashboard")
        
        cell.textLabel?.text = "Test"
        
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
