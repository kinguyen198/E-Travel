//
//  CustomInfoWindow.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/18/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit

class CustomInfoWindow: UIView {


    @IBOutlet weak var lblNameSpot: UILabel!
    @IBOutlet weak var lblAddressSpot: UILabel!
    @IBOutlet weak var lblPriceSpot: UILabel!

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnInfo: UIButton!
    @IBAction func btnMoreDetail(_ sender: Any) {
    }

    var view:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func loadView() -> CustomInfoWindow{
        let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
        return customInfoWindow
    }

}
