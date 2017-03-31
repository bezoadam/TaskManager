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
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "TableCell",
                                          for: indexPath)
        cell.textLabel?.text = name.value(forKeyPath: "name") as? String
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = true
        
        return cell
    }
}

