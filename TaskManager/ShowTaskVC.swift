//
//  ShowTaskVC.swift
//  TaskManager
//
//  Created by Adam Bezák on 31.3.17.
//  Copyright © 2017 Adam Bezák. All rights reserved.
//

import UIKit
import CoreData

class ShowTaskVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var singleTask: NSManagedObject?
    var categories: [NSManagedObject] = []
    var newSelectedCategory: NSManagedObject?
    var newEndDate: Date?
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var categoryName: UIPickerView!
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        let managedContext = getContext()
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Categories")
        
        do {
            categories = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        createDatePicker()
        
        self.taskName.text = self.singleTask?.value(forKey: "name") as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let date_tmp = self.singleTask?.value(forKey: "endDate") as? Date
        datePicker.date = date_tmp!
        self.endDate.text = dateFormatter.string(from: date_tmp!)
        
        let isFinished_tmp = self.singleTask?.value(forKey: "isFinished") as? Bool
        if isFinished_tmp == true {
            doneSwitch.setOn(true, animated: true)
        }
        else {
            doneSwitch.setOn(false, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        endDate.inputAccessoryView = toolbar
        endDate.inputView = datePicker
        
    }
    
    func donePressed() {
        
        self.newEndDate = datePicker.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        endDate.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    //MARK PickerView methods
    
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
        self.newSelectedCategory = categories[row]
    }
}
