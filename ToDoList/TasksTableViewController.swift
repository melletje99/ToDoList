//
//  TasksTableViewController.swift
//  ToDoList
//
//  Created by Wessel Mel on 26/11/2018.
//  Copyright © 2018 Wessel Mel. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController, ToDoCellDelegate, UISearchBarDelegate {
    var todos = [ToDo]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredData = [ToDo]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedToDos = ToDo.loadToDos() {
            todos = savedToDos
        } else {
            todos = ToDo.loadSampleToDos()
        }
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        } else {
            return todos.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier") as? ToDoCell else {
            fatalError("Could not dequeue a cell")
        }
        cell.delegate = self
        var todo: ToDo
        if isSearching {
            todo = filteredData[indexPath.row]
        } else {
            todo = todos[indexPath.row]
        }
        
        
        cell.titleLabel?.text = todo.title
        cell.isCompleteButton.isSelected = todo.isComplete
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isSearching {
                let removed = filteredData.remove(at: indexPath.row)
                
                for i in 0...(todos.count - 1 ) {
                    if todos[i].title == removed.title {
                        todos.remove(at: i)
                    }
                }
            } else {
                todos.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            ToDo.saveToDos(todos)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let todoTableViewController = segue.destination as! ToDoTableViewController
            let indexPath = tableView.indexPathForSelectedRow!
            var selectedTodo: ToDo
            if isSearching {
                selectedTodo = filteredData[indexPath.row]
            } else {
                selectedTodo = todos[indexPath.row]
            }
            todoTableViewController.todo = selectedTodo
        }
    }
    
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender){
            if isSearching {
                var todo = filteredData[indexPath.row]
                todo.isComplete = !todo.isComplete
                filteredData[indexPath.row] = todo
                tableView.reloadRows(at: [indexPath], with: .automatic)
                for i in 0...(todos.count - 1) {
                    if todos[i].title == filteredData[indexPath.row].title {
                        todos[i] = filteredData[indexPath.row]
                    }
                }
            } else {
                var todo = todos[indexPath.row]
                todo.isComplete = !todo.isComplete
                todos[indexPath.row] = todo
                tableView.reloadRows(at: [indexPath], with: .automatic)
                ToDo.saveToDos(todos)
            }
            
        }
    }
    
    @IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! ToDoTableViewController
        
        if let todo = sourceViewController.todo{
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if isSearching {
                    filteredData[selectedIndexPath.row] = todo
                    for i in 0...(filteredData.count - 1) {
                        for j in 0...(todos.count - 1 ) {
                            if filteredData[i].title == todos[j].title {
                                todos[j] = filteredData[i]
                            }
                        }
                    }
                } else {
                    todos[selectedIndexPath.row] = todo
                }
                
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: todos.count, section: 0)
                todos.append(todo)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        ToDo.saveToDos(todos)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filteredData = todos.filter({$0.title == searchBar.text!})
            tableView.reloadData()
        }
    }
    
    
}
