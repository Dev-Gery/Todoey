//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: UITableViewController {
    var todoItems = [TodoItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var navigation: UINavigationController?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        //        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navbar = navigationController?.navigationBar else { fatalError("Navigation Controller is nil")}
        
        let categoryColor = UIColor(hexString: (selectedCategory?.hexcolour) ?? "#007AFF")
        
        let contrastCategoryColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor!, isFlat: true)
        
//        navBar.barTintColor = categoryColor
        
        navbar.tintColor = contrastCategoryColor
        
        searchBar.barTintColor = categoryColor
        searchBar.searchTextField.backgroundColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = categoryColor
        appearance.largeTitleTextAttributes = [.foregroundColor: contrastCategoryColor]
        appearance.titleTextAttributes = [.foregroundColor: contrastCategoryColor]
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: contrastCategoryColor]
        
        navbar.scrollEdgeAppearance = appearance
        navbar.standardAppearance = appearance
//        navBar.scrollEdgeAppearance?.backgroundColor = categoryColor
//        
//        navBar.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: contrastCategoryColor]
//        
//        navBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: contrastCategoryColor]
//        
//        navBar.scrollEdgeAppearance?.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: contrastCategoryColor]
//                
//        navBar.standardAppearance.backgroundColor = categoryColor
//        
//        navBar.standardAppearance.titleTextAttributes = [.foregroundColor: contrastCategoryColor]
//        
//        navBar.standardAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: contrastCategoryColor]
        
        //        let appearance = UINavigationBarAppearance()
        //
        //        appearance.titleTextAttributes
    }
    
    var selectedCategory: TodoCategory? {
        didSet {
            loadData()
            navigationItem.title = selectedCategory?.name
        }
    }
    
    func loadData(with request: NSFetchRequest<TodoItem>) {
        do {
            todoItems = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", selectedCategory!)
        loadData(with: request)
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    
    //MARK: TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    //MARK: Cell Accessory View
    class CustomCheckmarkView: UIImageView {
        init(color: UIColor) {
            super.init(frame: .zero)
            let image = UIImage(systemName: "checkmark")?.withTintColor(color, renderingMode: .alwaysOriginal)
            self.image = image
            self.contentMode = .scaleAspectFit
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.widthAnchor.constraint(equalToConstant: 24),
                self.heightAnchor.constraint(equalToConstant: 24)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = todoItems[indexPath.row]
        cell.textLabel?.text = item.title
//        cell.accessoryType = item.done ? .checkmark : .none
        let color = UIColor(hexString: (selectedCategory?.hexcolour) ?? "#007AFF")
        
        cell.backgroundColor = color?.darken(byPercentage: CGFloat(Float(indexPath.row) / Float(todoItems.count)) )
        
        let backgroundContrastColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: true)
        
        cell.textLabel?.textColor = backgroundContrastColor
        cell.accessoryView = item.done ? CustomCheckmarkView(color: backgroundContrastColor) : .none
        return cell
    }
    
    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        saveData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            self.context.delete(self.todoItems[indexPath.row])
            self.todoItems.remove(at: indexPath.row)
            self.saveData()
            self.loadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    //MARK: Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
        }
        let action = UIAlertAction(title: "Add item", style: .default) { act in
            print("Success!")
            if let txt = alert.textFields?[0].text {
                if txt.contains(/[\w]/) {
                    let newTodoItem = TodoItem(context: self.context)
                    newTodoItem.title = txt
                    newTodoItem.category = self.selectedCategory
                    self.todoItems.append(newTodoItem)
                    self.saveData()
                    self.tableView.reloadData()
                }
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension TodoListViewController: UISearchBarDelegate {
    //MARK: SearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.contains(/[\w]/) {
//            let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
//            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ AND category == %@", searchBar.text!, selectedCategory!)
//            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//            loadData(with: request)
            
            //alternative using array filtering on the existing todoItems
            todoItems = todoItems.filter { $0.title!.lowercased().contains(searchBar.text!.lowercased()) }
            tableView.reloadData()
        } else {
            loadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}

