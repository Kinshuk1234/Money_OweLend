//
//  FriendListTableViewCell.swift
//  Money Owelend - Your personal accountant
//
//  Created by Kinshuk Singh on 2017-08-27.
//  Copyright © 2017 Ksk. All rights reserved.
//

import UIKit

class FriendListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
