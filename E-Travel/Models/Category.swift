//
//  Category.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/24/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
import UIKit

class Category{
    public  var id:String?
    public  var name:String?

    struct CategoryKey {
        let id = "_id"
        let name = "name"
    }

    init(id:String,name:String) {
        self.id = id
        self.name = name
    }
    public static let ArrayCategory :[Category] = [
        Category(id:"5e65c9b3f2527209d2d66b01",name:"Special"),
        Category(id:"5e6608d18f8c030008343d16",name:"Stay"),
        Category(id:"5e6894a73e20aa00087fe8a6",name:"Food"),
    ]

}
