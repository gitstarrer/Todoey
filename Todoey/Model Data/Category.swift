//
//  Category.swift
//  Todoey
//
//  Created by Himanshu Gupta on 03/07/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var hex : String = ""
    //forward relationship
    let items = List<Item>()
}
