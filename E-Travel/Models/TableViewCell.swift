//
//  TableViewCell.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/11/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblNameTrip: UILabel!
    @IBOutlet weak var lblAddressTrip: UILabel!
    @IBOutlet weak var lblTimeTrip: UILabel!
    @IBOutlet weak var lblWeatherDescription: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblMovingTime: UILabel!
    
    @IBOutlet weak var btnInfoSpot: UIButton!
    @IBOutlet weak var contentCell: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
}
