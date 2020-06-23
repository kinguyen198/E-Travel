//
//  ScheduleTableViewCell.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/23/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblTimeStart: UILabel!
    @IBOutlet weak var lblTimeEnd: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblNumOfSpot: UILabel!
    @IBOutlet weak var contentCell: UIView!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
