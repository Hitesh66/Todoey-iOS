//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hitesh Dayaramani on 7/28/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import Chameleon

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    var categories: Results<Category>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist")
        }
        navBar.backgroundColor = UIColor(hexString: "FFFFFF")
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(contrastingBlackOrWhiteColorOn:UIColor(hexString: "FFFFFF")!, isFlat:true)]
    }


    // MARK: - Table view data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"
            cell.backgroundColor = UIColor(hexString: (categories?[indexPath.row].colour) ?? "1D9BF6")
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:cell.backgroundColor!, isFlat:true)
        return cell
    }


    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation methods
    
    func save(category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        
        
        tableView.reloadData()
    }
    
    //MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
                    if let currentCategory = self.categories?[indexPath.row]{
                        do{
                            try self.realm.write{
                                self.realm.delete(currentCategory)
                            }
                        }catch{
                            print("Error in updating the done property \(error)")
                        }
                    }
    }
    

    
    //MARK: - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()

            self.save(category: newCategory)
        }
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        present(alert, animated: true,completion: nil)
    }

}
