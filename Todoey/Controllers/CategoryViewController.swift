//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Himanshu Gupta on 28/06/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        // print("Loaded Successfully")
        tableView.separatorStyle = .singleLine
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else{
            fatalError("navigation controller does not exist")
        }
        self.navigationController?.hidesNavigationBarHairline = true
        navBar.backgroundColor = UIColor.flatMint().lighten(byPercentage: CGFloat( 0.125))
    }
    
    // MARK: - Table view Datasource
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        if let safeColour = categories?[indexPath.row].hex {
            cell.backgroundColor = UIColor.init(hexString: safeColour)
             cell.textLabel?.textColor = ContrastColorOf(UIColor.init(hexString: safeColour)!, returnFlat: true)
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    
    
    
    //MARK: - Data Manipulation Methods
    func saveCategories(category : Category){
        //to commit the changes to the persistant container.
        do{
            try realm.write{
                realm.add(category)
            }
        }
        catch{
            print("Error saving category: \(error)")
        }
        super.tableView.reloadData()
    }
    
    func loadCategories(){
        //in order to read from the database and write into the array.
        categories = realm.objects(Category.self)
        super.tableView.reloadData()
    }
    
    
    
    //MARK: - Delete Data from swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let safeCategories = self.categories?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(safeCategories)
                }
            }
            catch{
                print("errOr deleting category!!")
            }
        }
    }
    
    
    //MARK: - Add button Pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new Category", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancel) in }
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.hex = RandomFlatColorWithShade(.light).hexValue()
            //self.categories.append(newCategory)
            self.saveCategories(category: newCategory)
        }
        alert.addAction(action)
        alert.addAction(cancel)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new item"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
        
    }
    
}

