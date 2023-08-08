//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import Chameleon

class ToDoListViewController: SwipeTableViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()
    var selectedCategory:Category? {
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

//    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour{
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation Controller does not exist")
            }
            if let navBarColor = UIColor(hexString: colourHex){
                navBar.backgroundColor = navBarColor
                navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn:navBarColor, isFlat:true)
                searchBar.barTintColor = navBarColor
                navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(contrastingBlackOrWhiteColorOn:navBarColor, isFlat:true)]
            }
            
        }
    }

    
    //MARK: - Table View Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.backgroundColor = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count))
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:cell.backgroundColor!, isFlat:true)
            cell.accessoryType = item.done ? .checkmark : .none;
        }else{
            cell.textLabel?.text = "No items added"
        }
        return cell
    }
    
    //MARK: - Table View Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print("Error in updating the done property \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch{
                    print("Error in adding category \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    //MARK: - Model Manupulation methods
    
 
    
    func loadItems(){
//        print(request)
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate{
//            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
//            request.predicate = compoundPredicate
//        }else{
//            request.predicate = categoryPredicate
//        }
//
//        do{
//            itemArray = try context.fetch(request)
//
//        }catch{
//            print("Error fetching data from context \(error)")
//        }
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title",ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
                    if let currentItem = self.todoItems?[indexPath.row]{
                        do{
                            try self.realm.write{
                                self.realm.delete(currentItem)
                            }
                        }catch{
                            print("Error in updating the done property \(error)")
                        }
                    }
    }
    

}

//MARK: - SearchBar methods

extension ToDoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated",ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}

