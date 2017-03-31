//
//  AddTaskVC.swift
//  TaskManager
//
//  Created by Adam Bezák on 30.3.17.
//  Copyright © 2017 Adam Bezák. All rights reserved.
//

import UIKit
import CoreData

class AddTaskVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var cancelBar: UIBarButtonItem!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var taskNameField: UITextField!

    var categories: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //nacitanie ulozenych kategorii
        let managedContext = getContext()
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Categories")
        
        do {
            categories = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
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

    //Pickerview DataSource methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let category = self.categories[row]
        let row = category.value(forKey: "name") as? String
        let color = category.value(forKey: "color") as? UIColor
        return NSAttributedString(string: row!, attributes: [NSForegroundColorAttributeName: color!])
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
}
