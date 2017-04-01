//
//  AddTaskVC.swift
//  TaskManager
//
//  Created by Adam Bezák on 30.3.17.
//  Copyright © 2017 Adam Bezák. All rights reserved.
//

import UIKit
import CoreData
import SCLAlertView

class AddTaskVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var cancelBar: UIBarButtonItem!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var endDateField: UITextField!
    
    @IBOutlet weak var taskNameField: UITextField!

    var categories: [NSManagedObject] = []
    var selectedCategory: NSManagedObject!
    let datePicker = UIDatePicker()
    var endDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
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
        
        //defaultne prva kategoria
        self.selectedCategory = categories[0]
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        endDateField.inputAccessoryView = toolbar
        endDateField.inputView = datePicker
        
    }
    
    func donePressed() {
        
        self.endDate = datePicker.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        endDateField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }

    func save(name: String, isFinished: Bool, category: NSManagedObject, endDate: Date) {
        
        let managedContext = getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Tasks",
                                       in: managedContext)!
        
        let task = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
        
        task.setValue(name, forKeyPath: "name")
        task.setValue(isFinished, forKey: "isFinished")
        task.setValue(endDate, forKey: "endDate")
        task.setValue(category, forKey: "category")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "unwindToMainVCSave" {
            if ((self.taskNameField.text?.characters.count)! > 0 &&
                (self.endDateField.text?.characters.count)! > 0) {
                return true
            }
            else {
                let alertError = SCLAlertView()
                alertError.addButton("OK", target:self, selector:#selector(AddTaskVC.okButton))
                alertError.showError("Error", subTitle: "You need to enter name of task and select end date")
                
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier != "unwindToMainVCSave") {
            print("cancel")
            return
        }
        save(name: self.taskNameField.text!, isFinished: false, category: self.selectedCategory, endDate: self.endDate)
        
        let newTasktoAdd = NewTask()
        newTasktoAdd.taskName = self.taskNameField.text!
        newTasktoAdd.isFinished = false
        newTasktoAdd.category = self.selectedCategory
        newTasktoAdd.endDate = self.endDate
        let destinationVC = segue.destination as! ViewController
        destinationVC.newTaskToAdd = newTasktoAdd
    }

    func okButton() {
        
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCategory = categories[row]
    }
}
