//
//  ReceivedTableViewCell.swift
//  Money Owelend - Your personal accountant
//
//  Created by Kinshuk Singh on 2017-08-27.
//  Copyright © 2017 Ksk. All rights reserved.
//

import UIKit
import Firebase

protocol ReceivedTableCellDelegate {

    func acceptButtonTapped(senderID: String, senderTag: Int)
    func declineButtonTapped(senderID: String, senderTag: Int)
    
}

class ReceivedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var hiddenIDLabel: UILabel!

    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var acceptButtonText: UIButton!
    
    var ref: DatabaseReference!
    
    var delegate: ReceivedTableCellDelegate?
    
    var receivedViewController: ReceivedViewController?
    
    let currentUserID = Auth.auth().currentUser?.uid

    
    @IBAction func acceptButton(_ sender: Any) {
        
        delegate?.acceptButtonTapped(senderID: hiddenIDLabel.text!, senderTag: (sender as AnyObject).tag)
        
    }
    
    @IBOutlet weak var declineButtonText: UIButton!
    
    @IBAction func declineButton(_ sender: Any) {
        
        delegate?.declineButtonTapped(senderID: hiddenIDLabel.text!, senderTag: (sender as AnyObject).tag)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        hiddenIDLabel.isHidden = true
        acceptButtonText.layer.cornerRadius = 4
        declineButtonText.layer.cornerRadius = 4
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
