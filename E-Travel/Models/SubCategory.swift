//
//  SubCategory.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/24/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
import UIKit
import RSSelectionMenu
class SubCategory :NSObject,UniqueProperty{
    func uniquePropertyName() -> String {
        return "id"
    }

    public  var id:String?
    public  var name:String?
    public  var parent_id:String?

//    struct SubCategoryKey {
//        let id = "_id"
//        let name = "name"
//        let parent_id = "parent_id"
//    }
    init(id:String,name:String,parent_id:String) {
        self.id = id
        self.name = name
        self.parent_id = parent_id
    }

    
    

}
//SubCategory(id:"5e65c9fbb918b409e1349f7c",name:"Mountain",parent_id:"5e65c9b3f2527209d2d66b01"),
//SubCategory(id:"5e6608e68f8c030008343d17",name:"Hotel", parent_id: "5e6608d18f8c030008343d16"),
//SubCategory(id:"5e6608f38f8c030008343d18",name:"Luxury", parent_id: "5e6608d18f8c030008343d16"),
//SubCategory(id:"5e660b008f8c030008343d19",name:"Homestay", parent_id: "5e6608d18f8c030008343d16"),
//SubCategory(id:"5e660b058f8c030008343d1a",name:"Cheap", parent_id: "5e6608d18f8c030008343d16"),
//SubCategory(id:"5e6608f38f8c030008343d18",name:"Luxury", parent_id: "5e65c9b3f2527209d2d66b01"),
//SubCategory(id:"5e675d5141076c1620ce8d05",name:"Bridge", parent_id: "5e65c9b3f2527209d2d66b01"),
//SubCategory(id:"5e6894993e20aa00087fe8a5",name:"Beach",parent_id:"5e65c9b3f2527209d2d66b01"),
//SubCategory(id:"5e6a0283eeec8116c8ce3f22",name:"Spicy", parent_id: "5e6894a73e20aa00087fe8a6"),
//SubCategory(id:"5e6aeeee5ecfe01c1cd41b6d",name:"Thai", parent_id: "5e6894a73e20aa00087fe8a6"),
//SubCategory(id:"5e6aeef85ecfe01c1cd41b6e",name:"Korea", parent_id: "5e6894a73e20aa00087fe8a6"),
//SubCategory(id:"5e6aeef85ecfe01c1cd41b6e",name:"Sweet Food", parent_id: "5e6894a73e20aa00087fe8a6"),
