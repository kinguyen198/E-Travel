//
//  Place.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/18/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
import UIKit
struct Place {
    let id:String
    let name:String
    let description:String
    let address:String
    let latitude:Double
    let longtitude:Double
    let category:String
    let subcategory:String
    let price:String
    var image = [String]()
    init(id:String,name:String, description:String,address:String,latitude:Double,longtitude:Double,category:String,subcategory:String,price:String,image:[String]) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.latitude = latitude
        self.longtitude = longtitude
        self.category = category
        self.subcategory = subcategory
        self.price = price
        self.image = image
    }

}

