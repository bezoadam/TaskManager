//
//  SettingsVC.swift
//  TaskManager
//
//  Created by Adam Bezák on 30.3.17.
//  Copyright © 2017 Adam Bezák. All rights reserved.
//

import UIKit
import CoreData
import SCLAlertView

class SettingsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    
    var categories: [NSManagedObject] = []
    var collectionViewAlert: UICollectionView!
    var newTaskName: String!
    var newTaskColor: UIColor!
    var selectedCategoryRow: NSInteger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let managedContext = getContext()
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Categories")
        
        //3
        do {
            categories = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = self.categories[indexPath.row]
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "TableCell",
                                          for: indexPath)
        cell.textLabel?.text = name.value(forKeyPath: "name") as? String
        cell.textLabel?.backgroundColor = UIColor.clear
        let bgColor = name.value(forKey: "color") as? UIColor
        cell.backgroundColor = bgColor?.withAlphaComponent(0.2)
        cell.isUserInteractionEnabled = true

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedCategoryRow = indexPath.row
        let alertView = SCLAlertView()
        
        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.itemSize = CGSize(width: 25, height: 25)
        
        collectionViewAlert = UICollectionView(frame: CGRect(x: 18, y: 10, width: 250, height: 30), collectionViewLayout: layout)
        collectionViewAlert.dataSource = self
        collectionViewAlert.delegate = self
        collectionViewAlert.restorationIdentifier = "EditColorCollectionView"
        collectionViewAlert.isUserInteractionEnabled = true
        collectionViewAlert.allowsMultipleSelection = false
        collectionViewAlert.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollCell")
        collectionViewAlert.backgroundColor = UIColor.white
        
        
        let subview = UIView(frame: CGRect(x:0,y:0,width:216,height:60))
        subview.addSubview(self.collectionViewAlert)
        subview.isUserInteractionEnabled = true
        
        alertView.customSubview = subview
        alertView.addButton("Close", target: self, selector: #selector(AlertViewClosePressed))
        alertView.addButton("Save", target: self, selector: #selector(AlertViewSavePressed))
        alertView.showEdit("Choose new color", subTitle: "This alert view has buttons")
        
    }
    
    func AlertViewSavePressed(_ sender:UIButton) {
        update(index: self.selectedCategoryRow, color: self.newTaskColor)
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let alertView = SCLAlertView()
        

        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.itemSize = CGSize(width: 25, height: 25)
        
        collectionViewAlert = UICollectionView(frame: CGRect(x: 18, y: 10, width: 250, height: 30), collectionViewLayout: layout)
        collectionViewAlert.dataSource = self
        collectionViewAlert.delegate = self
        collectionViewAlert.restorationIdentifier = "AlertCollectionView"
        collectionViewAlert.isUserInteractionEnabled = true
        collectionViewAlert.allowsMultipleSelection = false
        collectionViewAlert.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollCell")
        collectionViewAlert.backgroundColor = UIColor.white
        
        // Add textfield 1
        let textfield = UITextField(frame: CGRect(x: 7, y: 50, width: 202, height: 27))
        textfield.layer.borderColor = UIColor.black.cgColor
        textfield.layer.borderWidth = 1.0
        textfield.layer.cornerRadius = 5
        textfield.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        textfield.placeholder = "Enter category name"
        textfield.textAlignment = NSTextAlignment.center
        
        let subview = UIView(frame: CGRect(x:0,y:0,width:216,height:80))
        subview.addSubview(self.collectionViewAlert)
        subview.isUserInteractionEnabled = true
        subview.addSubview(textfield)
        
        alertView.customSubview = subview
        alertView.addButton("Close", target: self, selector: #selector(AlertViewClosePressed))
        alertView.addButton("Submit", target: self, selector: #selector(AlertViewSubmitPressed))
        alertView.showEdit("Choose color", subTitle: "This alert view has buttons")

    }
    
    func textFieldDidChange(textField: UITextField) {
        self.newTaskName = textField.text
    }
    
    func AlertViewSubmitPressed(_ sender:UIButton) {
        save(name: self.newTaskName, color: self.newTaskColor)
    }

    func AlertViewClosePressed(_ sender:UIButton) {
        self.newTaskName = nil
        self.newTaskColor = nil
        self.selectedCategoryRow = nil
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        deleteRecords()
    }
    
    func save(name: String, color: UIColor) {
        
        let managedContext = getContext()
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Categories",
                                       in: managedContext)!
        
        let category = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        category.setValue(name, forKeyPath: "name")
        category.setValue(color, forKey: "color")
        
        // 4
        do {
            try managedContext.save()
            categories.append(category)
            TableView.reloadData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func update(index: NSInteger, color: UIColor) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.categories[index].setValue(color, forKey: "color")
        appDelegate.saveContext()
        TableView.reloadData()
    }
    
    func deleteRecords() -> Void {
        let moc = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        
        let result = try? moc.fetch(fetchRequest)
        let resultData = result as! [Categories]
        
        for object in resultData {
            moc.delete(object)
        }
        
        do {
            try moc.save()
            print("saved!")
            TableView.reloadData()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }

    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var colors = [UIColor.red, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.cyan]
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollCell", for: indexPath as IndexPath)
        
        cell.backgroundColor = self.colors[indexPath.item]
        return cell

    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.black.cgColor
        cell?.layer.borderWidth = 2.0
        
        if (collectionView.restorationIdentifier == "AlertCollectionView") {
            self.newTaskColor = cell?.backgroundColor
        }
        else if (collectionView.restorationIdentifier == "EditColorCollectionView") {
            self.newTaskColor = cell?.backgroundColor
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0.0
    }
    // MARK: - UICollectionViewDataSource protocol
    

}
