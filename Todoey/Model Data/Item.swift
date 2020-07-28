//
//  Item.swift
//  Todoey
//
//  Created by Himanshu Gupta on 03/07/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    
    @objc dynamic var dateCreated : Date? = nil
    
    //the reverse relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
