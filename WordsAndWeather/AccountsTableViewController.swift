//
//  AccountsTableViewController.swift
//  SwiftCrashCourseApp
//
//  Created by Franks, Kent on 11/5/15.
//  Copyright © 2015 Franks, Kent. All rights reserved.
//

import UIKit
import CoreData

class AccountsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Core Data vars
    /* coreDataController was injected from the app delegate */
    var persistenceController: PersistenceController?
    var mainContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let persistenceController = persistenceController {
            /* get the main moc from the persistenceController */
            mainContext = persistenceController.mainMoc
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred while performing the fetch")
        }
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(atIndexPath: indexPath)
    }
    
    func configureCell(atIndexPath indexPath: IndexPath)  -> AccountTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountTableViewCell
        let account = fetchedResultsController.object(at: indexPath) as! Account
        cell.accountNameLabel.text = account.accountName
        cell.accountUsernameLabel.text = account.username
        cell.accountPasswordLabel.text = account.password
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let account = fetchedResultsController.object(at: indexPath) as? Account
            mainContext?.delete(account!)
            persistenceController!.saveContext({
                (response, error) -> Void in
            })
        }
    }
    
    // MARK: - Core Data
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> <<error type>> in 
        let accountsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let primarySortDescriptor = NSSortDescriptor(key: "accountName", ascending: true, selector: "caseInsensitiveCompare:")
        accountsFetchRequest.sortDescriptors = [primarySortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: accountsFetchRequest, managedObjectContext: self.mainContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath, indexPath != newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addEditViewController = segue.destination as! AddEditViewController
        addEditViewController.persistenceController = self.persistenceController
        if segue.identifier == Constants.editAccountSegue {
            let indexPath = self.tableView.indexPathForSelectedRow
            addEditViewController.account = fetchedResultsController.object(at: indexPath!) as? Account
            addEditViewController.saveActionType = false
        } else if segue.identifier == Constants.addAccountSegue {
            addEditViewController.saveActionType = true
        }
    }
    
    
}
