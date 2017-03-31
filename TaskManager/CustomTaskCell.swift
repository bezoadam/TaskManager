//
//  CustomTaskCell.swift
//  TaskManager
//
//  Created by Adam Bezák on 31.3.17.
//  Copyright © 2017 Adam Bezák. All rights reserved.
//

import UIKit

class CustomTaskCell: UITableViewCell {

    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var taskDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
