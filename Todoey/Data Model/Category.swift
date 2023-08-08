//
//  Category.swift
//  Todoey
//
//  Created by Hitesh Dayaramani on 7/31/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name : String = ""
    @objc dynamic var colour : String = ""
    let items = List<Item>()
}
