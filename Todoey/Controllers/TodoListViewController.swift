//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    var todoItems = [TodoItem]()
//    let dataFilePath = FileMaager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appe*/ndingPathComponent("TodoItems.plist")
        
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadData()
    }
    
//    func loadData() {
//        if let data = try? Data(contentsOf: (dataFilePath ?? URL(string: "")) ?? URL(string: "")!) {
//            let decoder = PropertyListDecoder()
//            do {
//                todoItems = try decoder.decode([TodoItem].self, from: data)
//            } catch {
//                print("Error decoding data: \(error)")
//            }
//        }
//        else {
//            todoItems.append(TodoItem(title: "Study iOS Dev"))
//            todoItems.append(TodoItem(title: "Breakfast"))
//            todoItems.append(TodoItem(title: "Contact Stephanie"))
//        }
//    }
    
    //MARK - TableView DataSource Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = todoItems[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    //MARK - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//        saveData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func saveData() {
//        let encoder = PropertyListEncoder()
//        do {
//            let data = try encoder.encode(self.todoItems)
//            try data.write(to: self.dataFilePath!)
//        } catch {
//            print("Error encoding item array, \(error)")
//        }
//    }
    
    //MARK - Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
        }
        let action = UIAlertAction(title: "Add item", style: .default) { act in
            print("Success!")
            if let txt = alert.textFields?[0].text {
                if !txt.isEmpty {
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let newTodoItem = TodoItem(context: context)
                    newTodoItem.title = txt
                    self.todoItems.append(newTodoItem)
//                    self.saveData()
                    self.tableView.reloadData()
                }
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

