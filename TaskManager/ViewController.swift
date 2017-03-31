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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
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
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    @IBAction func unwindToMainVC(segue: UIStoryboardSegue){
        if let _ = self.newTaskToAdd {
            getData()
            tableView.reloadData()
        }
    }

    //MARK TableView methods
    
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
        cell.isUserInteractionEnabled = true
        
        return cell
    }
}

