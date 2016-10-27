//
//  TaskList.swift
//  RealmDemo
//
//  Created by yamaguchi on 2016/10/27.
//  Copyright © 2016年 h.yamaguchi. All rights reserved.
//

import UIKit
import RealmSwift

class TaskList: Object {
    
    dynamic var text = ""
    dynamic var id = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
