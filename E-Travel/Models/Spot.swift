//
//  Spot.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/23/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
class Spot {
    let name:String
    let description:String
    let address:String
    let latitude:Double
    let longtitude:Double
    let currentTime:Double
    var temperature:String = ""
    var sumary:String = ""
    let distance:Double
    let movingTime:Double
    var images = [String]()
    var price:String = ""
    var category:String = ""
    var subcategory:String = ""
    init(name:String, description:String,address:String,latitude:Double,longtitude:Double,currentTime:Double,distance:Double,movingTime:Double) {
        self.name = name
        self.description = description
        self.address = address
        self.latitude = latitude
        self.longtitude = longtitude
        self.currentTime = currentTime
        self.distance = distance
        self.movingTime = movingTime
    }
    init(name:String, description:String,address:String,latitude:Double,longtitude:Double,currentTime:Double,distance:Double,movingTime:Double,image:[String],price:String,category:String,subCategory:String) {
        self.name = name
        self.description = description
        self.address = address
        self.latitude = latitude
        self.longtitude = longtitude
        self.currentTime = currentTime
        self.distance = distance
        self.movingTime = movingTime
        self.images = image
        self.price = price
        self.category = category
        self.subcategory = subCategory
    }
 
}
