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
    var taskName: String!
    var isFinished: Bool!
    var endDate: Date!
    var category: NSManagedObject!
}
