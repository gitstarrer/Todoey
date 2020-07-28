//
//  ViewController.swift
//  Todoey
//
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var toDoItems : Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // tableView.separatorStyle =  .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let hexColour = selectedCategory?.hex{
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else{
                fatalError("navigation controller does not exist")
            }
            
            if let navColor = UIColor(hexString: hexColour) {
                navBar.backgroundColor = navColor
                navBar.tintColor = ContrastColorOf(navColor , returnFlat: true)
                searchBar.barTintColor = navColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navColor, returnFlat: true) ]
                searchBar.searchTextField.backgroundColor = .flatWhite()
            }
        }
    }
    
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    
    
    //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = (item.done == true) ? .checkmark : .none
            
            if let colour = UIColor(hexString : selectedCategory!.hex)?.darken(byPercentage: CGFloat(Float(indexPath.row) / Float(toDoItems!.count+10))){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        }
        //}
        return cell
    }
    
    
    
    
    //MARK: - TableView Delegate Methods.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do{
                try realm.write{
                    item.done = !item.done
                }
            }
            catch{
                print("eRRor saving done status, \(error)")
            }
        }
        tableView.reloadData() //forcefully calls the datasource methods and reload the data to display it in the table
    }
    
    
    
    
    //MARK: - Add Items to the List
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "Give your Item a title!", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancel) in }
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("ErROr saving new items")
                }
            }
            self.tableView.reloadData()
            //newItem.parentCategory = self.selectedCategory
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new item"
            textField = alertTextField
        }
        alert.addAction(cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: - Data manipulation functions
    
    
    func loadItems() {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        
    }
    override func updateModel(at indexPath: IndexPath) {
        if let safeItems = self.toDoItems?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(safeItems)
                }
            }
            catch{
                print("errOr deleting category!!")
            }
        }
    }
}



//MARK: - Search Bar Methods
extension ToDoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {//so that this happens in the main thread.
                searchBar.resignFirstResponder() //no longer remains selected and the keyboard pops.
            }
            
        }
    }
}
