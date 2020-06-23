//
//  MyTripTableViewCell.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/22/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit

class MyTripTableViewCell: UITableViewCell {

    @IBOutlet weak var lblNameTrip: UILabel!
    @IBOutlet weak var lblDateStart: UILabel!
    @IBOutlet weak var lblDateEnd: UILabel!
    @IBOutlet weak var lblNumberOfDay: UILabel!
    @IBOutlet weak var lblBudget: UILabel!
    @IBOutlet weak var lblNumOfPeople: UILabel!
    @IBOutlet weak var contentCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
