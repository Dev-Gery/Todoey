//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Gery J. Sumual on 27/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categories = [TodoCategory]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navbar = navigationController?.navigationBar else { fatalError("Navigation Controller is nil")}
        
        let navbarColor = UIColor(hexString: "#007AFF")
        let navbarContrastColor = UIColor(contrastingBlackOrWhiteColorOn: navbarColor!, isFlat: true)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = navbarColor
        appearance.largeTitleTextAttributes = [.foregroundColor: navbarContrastColor]
        appearance.titleTextAttributes = [.foregroundColor: navbarContrastColor]
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: navbarContrastColor]
        
        navbar.scrollEdgeAppearance = appearance
        navbar.standardAppearance = appearance
    }
    
    
    func loadData(with request: NSFetchRequest<TodoCategory>) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
        let request: NSFetchRequest<TodoCategory> = TodoCategory.fetchRequest()
        loadData(with: request)
        tableView.reloadData()
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: Add New Category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { UITextField in
            UITextField.placeholder = "Name"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let inputText = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) {
                if inputText.isEmpty {
                    ()
                } else {
                    let newCategory = TodoCategory(context: self.context)
                    newCategory.name = inputText
                    newCategory.hexcolour = UIColor.randomFlat().hexValue()
                    self.saveData()
                    self.loadData()
                }
            }
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.backgroundColor = UIColor.init(hexString: categories[indexPath.row].hexcolour ?? "#007AFF")
        
        var content = cell.defaultContentConfiguration()
        content.text = categories[indexPath.row].name
        content.textProperties.color = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: true)
        
        cell.contentConfiguration = content
        return cell
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            self.context.delete(self.categories[indexPath.row])
            self.categories.remove(at: indexPath.row)
            self.saveData()
            self.loadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoItems" {
            let destinationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories[indexPath.row]
            }
        } else {
            ()
        }
    }
    
    
}
