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
import DLRadioButton

class SettingsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var categories: [NSManagedObject] = []
    var collectionViewAlert: UICollectionView!
    var newCategoryName: String!
    var newCategoryColor: UIColor!
    var editedColor: UIColor!
    var selectedCategoryRow: NSInteger!
    var orderBy: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let _ = self.orderBy {
            if self.orderBy == "orderByName" {
                self.nameLabel.textColor = UIColor.blue
            }
            else {
                self.dateLabel.textColor = UIColor.blue
            }
        }
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
        cell.selectionStyle = .none
        let bgColor = name.value(forKey: "color") as? UIColor
        cell.backgroundColor = bgColor?.withAlphaComponent(0.2)
        cell.isUserInteractionEnabled = true

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedCategoryRow = indexPath.row
        let alertView = SCLAlertView()
        
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
        alertView.addButton("Back", target: self, selector: #selector(chooseColorClosePressed))
        alertView.showEdit("Choose new color", subTitle: "This alert view has buttons")
        
    }

    func chooseColorClosePressed(_ sender:UIButton) {
        self.categories[self.selectedCategoryRow].setValue(editedColor, forKey: "color")
        tableView.reloadData()
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let alertView = SCLAlertView()

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
        self.newCategoryName = textField.text
    }
    
    func AlertViewSubmitPressed(_ sender:UIButton) {
        let managedContext = getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Categories",
                                       in: managedContext)!
        
        let category = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
        category.setValue(self.newCategoryName, forKey: "name")
        category.setValue(self.newCategoryColor, forKey: "color")
        self.categories.append(category)
        tableView.reloadData()
    }

    func AlertViewClosePressed(_ sender:UIButton) {
        self.newCategoryName = nil
        self.newCategoryColor = nil
        self.selectedCategoryRow = nil
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        deleteRecords()
    }
    
    func save(name: String, color: UIColor) {
        
        let managedContext = getContext()

        let entity =
            NSEntityDescription.entity(forEntityName: "Categories",
                                       in: managedContext)!
        
        let category = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        category.setValue(name, forKeyPath: "name")
        category.setValue(color, forKey: "color")
        
        do {
            try managedContext.save()
            categories.append(category)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func update(index: NSInteger, color: UIColor) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.categories[index].setValue(color, forKey: "color")
        appDelegate.saveContext()
        tableView.reloadData()
    }
    
    //Pomocna metoda na odstranenie vsetkych kategorii
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
            tableView.reloadData()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier != "save") {
            let managedContext = getContext()
            managedContext.reset()
            return
        }
        else {
            if let _  = self.editedColor {
                update(index: self.selectedCategoryRow, color: self.editedColor)
            }
            if let _ = self.newCategoryName {
                save(name: self.newCategoryName, color: self.newCategoryColor)
            }
            if let _ = self.orderBy {
                let nav = segue.destination 
                let destinationVC = nav as! ViewController
                destinationVC.orderBy = self.orderBy
            }
            
        }
    }
    
    @IBAction func orderByName(_ sender: Any) {
        self.orderBy = "orderByName"
    }
    
    @IBAction func orderByDate(_ sender: Any) {
        self.orderBy = "orderByDate"
    }
    
    
    var colors = [UIColor.red, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.cyan]
    
    // MARK: - UICollectionViewDataSource protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollCell", for: indexPath as IndexPath)
        if (collectionView.restorationIdentifier == "AlertCollectionView") {
            cell.backgroundColor = self.colors[indexPath.item].withAlphaComponent(0.2)
        }
        else if (collectionView.restorationIdentifier == "EditColorCollectionView") {
            let color_tmp = self.colors[indexPath.item].withAlphaComponent(0.2)
            let categoryColor_tmp = self.categories[self.selectedCategoryRow].value(forKey: "color") as? UIColor

            if (color_tmp == categoryColor_tmp?.withAlphaComponent(0.2)){
                cell.layer.borderColor = UIColor.black.cgColor
                cell.layer.borderWidth = 2.0
                self.editedColor = color_tmp
            }
            cell.backgroundColor = color_tmp
        }
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.black.cgColor
        cell?.layer.borderWidth = 2.0
        
        if (collectionView.restorationIdentifier == "AlertCollectionView") {
            self.newCategoryColor = cell?.backgroundColor
        }
        else if (collectionView.restorationIdentifier == "EditColorCollectionView") {
            self.editedColor = cell?.backgroundColor
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0.0
    }

}
