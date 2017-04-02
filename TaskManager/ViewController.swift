//
//  ViewController.swift
//  TaskManager
//
//  Created by Adam Bezák on 30.3.17.
//  Copyright © 2017 Adam Bezák. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var newTaskToAdd: NewTask?
    var tasks: [NSManagedObject] = []
    var selectedTask: NSManagedObject?
    var orderBy: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        singleTap.numberOfTapsRequired = 1

        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        
        singleTap.require(toFail: doubleTap)
        view.addGestureRecognizer(singleTap)
        view.addGestureRecognizer(doubleTap)
        
        
        ///Pridanie defaultnych kategorii
        if isAppAlreadyLaunchedOnce() == false {
            let managedContext = getContext()
            
            let entity =
                NSEntityDescription.entity(forEntityName: "Categories",
                                           in: managedContext)!
            
            let initCategory = ["Category 1", "Category 2", "Category 3", "Category 4"]
            let initColors = [UIColor.red.withAlphaComponent(0.2), UIColor.yellow.withAlphaComponent(0.2), UIColor.green.withAlphaComponent(0.2), UIColor.blue.withAlphaComponent(0.2)]
            
            for (index, element) in initCategory.enumerated() {
                
                let category = NSManagedObject(entity: entity,
                                               insertInto: managedContext)
                category.setValue(element, forKeyPath: "name")
                category.setValue(initColors[index], forKey: "color")
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
        
        ///posunitie zaciatku riadku v tableView
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        
        if let _ = self.orderBy {
            if self.orderBy == "orderByName" {
                let sortedResults = self.tasks.sorted(by: ({
                    let tmp1 = $0.value(forKey: "name") as! String
                    let tmp2 = $1.value(forKey: "name") as! String
                    return tmp1 < tmp2
                }))
                self.tasks = sortedResults
            }
            else {
                self.tasks = self.tasks.sorted(by: ({
                    let tmp1 = $0.value(forKey: "endDate") as! Date
                    let tmp2 = $1.value(forKey: "endDate") as! Date
                    return tmp1 < tmp2
                }))
            }
            tableView.reloadData()
        }
    }

    func handleSingleTap(recognizer: UIGestureRecognizer) {
        let p = recognizer.location(in: tableView)
        
        let indexPath = tableView.indexPathForRow(at: p)
        
        if let _ = indexPath {
            tableView.deselectRow(at: indexPath!, animated: true)
            self.selectedTask = tasks[(indexPath?.row)!]
            self.performSegue(withIdentifier: "showTask", sender: self)
        }
    }
    
    func handleDoubleTap(recognizer: UIGestureRecognizer) {
        let p = recognizer.location(in: tableView)
        
        let indexPath = tableView.indexPathForRow(at: p)
        
        if let _ = indexPath {
            tableView.deselectRow(at: indexPath!, animated: true)
            let isFinished_tmp = self.tasks[(indexPath?.row)!].value(forKey: "isFinished") as? Bool
            if isFinished_tmp == true {
                update(index: (indexPath?.row)!, isFinished: false)
            }
            else {
                update(index: (indexPath?.row)!, isFinished: true)
            }
        }
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func getData() {
        //nacitanie ulozenych taskov
        let managedContext = getContext()
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        
        do {
            self.tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    ///Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showTask") {
            let nav = segue.destination as! UINavigationController
            let destinationVC = nav.topViewController as! ShowTaskVC
            destinationVC.singleTask = self.selectedTask
        }
        else if (segue.identifier == "showSettings") {
            let nav = segue.destination as! UINavigationController
            let destinationVC = nav.topViewController as! SettingsVC
            destinationVC.orderBy = self.orderBy
        }
    }
    
    @IBAction func unwindToMainVC(segue: UIStoryboardSegue){
        if let _ = self.newTaskToAdd {
            getData()
        }
        tableView.reloadData()
    }
    
    func update(index: NSInteger, isFinished: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.tasks[index].setValue(isFinished, forKey: "isFinished")
        appDelegate.saveContext()
        tableView.reloadData()
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            return false
        }
    }
    
    /// TableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = self.tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! CustomTaskCell
        cell.taskName.text = name.value(forKey: "name") as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let date = name.value(forKey: "endDate") as? Date
        cell.taskDate.text = dateFormatter.string(from: date!)
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let category = name.value(forKey: "category") as? NSManagedObject
        let bgColor = category?.value(forKey: "color") as? UIColor
        cell.backgroundColor = bgColor?.withAlphaComponent(0.2)
        
        let isFinished = name.value(forKey: "isFinished") as? Bool
        
        if isFinished == true {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        cell.isUserInteractionEnabled = true
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let moc = appDelegate.persistentContainer.viewContext
            
            moc.delete(self.tasks[indexPath.row])
            appDelegate.saveContext()

            self.tasks.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

