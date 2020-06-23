//
//  File.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/22/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
import UIKit
class Trip:NSObject,NSCoding{
    func encode(with aCoder: NSCoder) {
        aCoder.encode(idTrip,forKey:"idTrip")
        aCoder.encode(nameTrip,forKey:"nameTrip")
        aCoder.encode(dateStart,forKey:"dateStart")
        aCoder.encode(dateEnd,forKey:"dateEnd")
        aCoder.encode(numberOfday,forKey:"numberOfday")
        aCoder.encode(numberOfAdult,forKey:"numberOfAdult")
        aCoder.encode(numberOfKid,forKey:"numberOfKid")
        aCoder.encode(budget,forKey:"budget")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let idTrip = aDecoder.decodeObject(forKey: "idTrip") as! String
        let nameTrip = aDecoder.decodeObject(forKey: "nameTrip")as! String
        let dateStart = aDecoder.decodeObject(forKey: "dateStart")as! String
        let dateEnd = aDecoder.decodeObject(forKey: "dateEnd")as! String
        let numberOfday = aDecoder.decodeObject(forKey: "numberOfday")as! Int
        let numberOfAdult = aDecoder.decodeObject(forKey: "numberOfAdult")as! Int
        let numberOfKid = aDecoder.decodeObject(forKey: "numberOfKid")as! Int
        let budget = aDecoder.decodeObject(forKey: "budget")as! Int
        self.init(id: idTrip, nameTrip: nameTrip, dateStart: dateStart, dateEnd: dateEnd, numberOfDay: numberOfday, numberOfAdult: numberOfAdult, numberOfKid: numberOfKid, budget: budget)
    }

    let idTrip:String
    let nameTrip:String
    let dateStart:String
    let dateEnd:String
    let numberOfday:Int
    let numberOfAdult:Int
    let numberOfKid:Int
    let budget:Int
    init(id:String,nameTrip:String,dateStart:String,dateEnd:String,numberOfDay:Int,numberOfAdult:Int,numberOfKid:Int,budget:Int) {
        self.idTrip = id
        self.nameTrip = nameTrip
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.numberOfday = numberOfDay
        self.numberOfAdult = numberOfAdult
        self.numberOfKid = numberOfKid
        self.budget = budget
    }

    static func saveData(arrayTrip : [Trip]) -> Data{
         return try! NSKeyedArchiver.archivedData(withRootObject: arrayTrip as Array, requiringSecureCoding: false)
    }
    static func loadData(unarchivedObject:Data)->[Trip]{
        return try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as! [Trip]
    }
}
