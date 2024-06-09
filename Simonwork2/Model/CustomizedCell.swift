//
//  CustomizedCell.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/10.
//

import UIKit

class CustomizedCell: UITableViewCell {

    @IBOutlet weak var letterTitleLable: UILabel!
    @IBOutlet weak var letterDateLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
