//
//  AddTaskVC.swift
//  TaskManager
//
//  Created by Adam Bezák on 30.3.17.
//  Copyright © 2017 Adam Bezák. All rights reserved.
//

import UIKit
import CoreData

class AddTaskVC: UIViewController {

    @IBOutlet weak var cancelBar: UIBarButtonItem!
    
    @IBOutlet weak var taskNameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier != "unwindToMainVCSave") {
            print("cancel")
            return
        }
        if ((self.taskNameField.text?.characters.count)! > 0) {
            let newTasktoAdd = NewTask()
            newTasktoAdd.taskName = self.taskNameField.text!
            newTasktoAdd.finished = false
            let destinationVC = segue.destination as! ViewController
            destinationVC.newTaskToAdd = newTasktoAdd
        }
    }

}
