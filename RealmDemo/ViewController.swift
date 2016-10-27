//
//  ViewController.swift
//  RealmDemo
//
//  Created by yamaguchi on 2016/10/27.
//  Copyright © 2016年 h.yamaguchi. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UITableViewController {
    
    var items = List<Task>()
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        self.notificationToken.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "TODO"
        self.view.backgroundColor = UIColor.white
        
        // tableView Setting
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // list
        self.items.append(Task(value: ["text": "My First Text"]))
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(add))
        // setRealm
        self.setupRealm()
        
    }

    // MARK: Private
    
    func setupRealm() {
        // Log in existing user with username and password
        let username = "test@test.com"
        let password = "testtest"
        
        SyncUser.authenticate(with: Credential.usernamePassword(username: username, password: password,
                                                                actions: []),
                              server: Constants.syncAuthURL!)
        { (user, error) in
            
            guard let user = user else {
                fatalError(String(describing: error))
            }
            
            let configuration = Realm.Configuration(
                syncConfiguration: (user, Constants.syncServerURL!)
            )
            
            self.realm = try! Realm(configuration: configuration)
            
            self.updateItems()
            
            // Notify us when Realm changes
            self.notificationToken = self.realm.addNotificationBlock { _ in
                self.updateItems()
            }
        }
    }
    
    func add() {
        
        let alertController = UIAlertController(title: "New Task", message: "Enter Task Name", preferredStyle: .alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Task Name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let text = alertTextField.text , !text.isEmpty else { return }
            guard let weakself = self else {
                return
            }
            
            weakself.items.append(Task(value: ["text": text]))
            weakself.tableView.reloadData()
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateItems() {
        if self.items.realm == nil, let list = self.realm.objects(TaskList.self).first {
            self.items = list.items
        }
        self.tableView.reloadData()
    }
    
    // MARK: TableView Delegate & DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.text
        cell.textLabel?.alpha = item.completed ? 0.5 : 1
        
        return cell
    }
}

