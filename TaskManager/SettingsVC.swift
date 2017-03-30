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
    
    @IBOutlet weak var categoryName: UITextField!
    
    @IBOutlet weak var TableView: UITableView!
    
    var categories: [NSManagedObject] = []
    var collectionViewAlert: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self

        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.itemSize = CGSize(width: 25, height: 25)
        
        collectionViewAlert = UICollectionView(frame: CGRect(x: 18, y: 10, width: 250, height: 25), collectionViewLayout: layout)
        collectionViewAlert.dataSource = self
        collectionViewAlert.delegate = self
        collectionViewAlert.reloadData()
        collectionViewAlert.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollCell")
        collectionViewAlert.backgroundColor = UIColor.white
//        self.view.addSubview(collectionViewAlert)
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
        cell.backgroundColor = name.value(forKey: "color") as? UIColor
        cell.isUserInteractionEnabled = false

        return cell
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let alertView = SCLAlertView()
        alertView.addTextField("Enter category name")

        let subview = UIView(frame: CGRect(x:0,y:0,width:216,height:70))
        subview.addSubview(self.collectionViewAlert)
        alertView.customSubview = subview
        alertView.showEdit("Choose color", subTitle: "This alert view has buttons")
//        alert.view.addSubview(self.collectionViewAlert)

        
//        let alert2 = UIAlertController(title: "New category",
//                                      message: "Add a new category name",
//                                      preferredStyle: .alert)
//        
//        let saveAction = UIAlertAction(title: "Save", style: .default) {
//            [unowned self] action in
//            
//            guard let textField = alert.textFields?.first,
//                let categoryToSave =  textField.text else {
//                    return
//            }
//            
//            self.save(name: categoryToSave)
//            self.TableView.reloadData()
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel",
//                                         style: .default)
//        
//        alert.addTextField()
//        
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
        
//        present(alert, animated: true)


    }

    @IBAction func deleteAll(_ sender: Any) {
        deleteRecords()
    }
    
    func save(name: String) {
        
        let managedContext = getContext()
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Categories",
                                       in: managedContext)!
        
        let category = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        category.setValue(name, forKeyPath: "name")
        category.setValue(UIColor.red, forKey: "color")
        
        // 4
        do {
            try managedContext.save()
            categories.append(category)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
        
        // get a reference to our storyboard cell
        if (collectionView == self.collectionViewAlert) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollCell", for: indexPath as IndexPath)
            cell.backgroundColor = self.colors[indexPath.item]
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath)
            
            cell.backgroundColor = self.colors[indexPath.item]// make cell more visible in our example project
            return cell
        }
        
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    // MARK: - UICollectionViewDataSource protocol
    

}
