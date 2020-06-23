//
//  Schedule.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/23/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
import UIKit
struct Schedule {
    var timeStart = Double()
    var timeEnd = Double()
    var distances = Double()
    var numOfSpot = Int()
    init(timeStart:Double,timeEnd:Double,distances:Double,numOfSpot:Int) {
        self.timeEnd = timeEnd
        self.timeStart = timeStart
        self.distances = distances
        self.numOfSpot = numOfSpot

    }
}
