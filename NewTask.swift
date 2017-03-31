//
//  NewTask.swift
//  TaskManager
//
//  Created by Adam Bezák on 31.3.17.
//  Copyright © 2017 Adam Bezák. All rights reserved.
//

import UIKit
import CoreData

class NewTask: NSManagedObject {
    var tastkName: String!
    var finished: Bool!
    var endTime: String!
    var category: NSManagedObject!
}
