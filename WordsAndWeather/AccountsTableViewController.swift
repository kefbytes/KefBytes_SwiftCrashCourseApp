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
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred while performing the fetch")
        }
        
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return configureCell(atIndexPath: indexPath)
    }
    
    func configureCell(atIndexPath indexPath: NSIndexPath)  -> AccountTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("accountCell", forIndexPath: indexPath) as! AccountTableViewCell
        let account = fetchedResultsController.objectAtIndexPath(indexPath) as! Account
        cell.accountNameLabel.text = account.accountName
        cell.accountUsernameLabel.text = account.username
        cell.accountPasswordLabel.text = account.password
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let account = fetchedResultsController.objectAtIndexPath(indexPath) as? Account
            mainContext?.deleteObject(account!)
            persistenceController!.saveContext({
                (response, error) -> Void in
            })
        }
    }
    
    // MARK: - Core Data
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let accountsFetchRequest = NSFetchRequest(entityName: "Account")
        let primarySortDescriptor = NSSortDescriptor(key: "accountName", ascending: true, selector: "caseInsensitiveCompare:")
        accountsFetchRequest.sortDescriptors = [primarySortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: accountsFetchRequest, managedObjectContext: self.mainContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let indexPath = indexPath {
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        case .Move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath where indexPath != newIndexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let addEditViewController = segue.destinationViewController as! AddEditViewController
        addEditViewController.persistenceController = self.persistenceController
        if segue.identifier == Constants.editAccountSegue {
            let indexPath = self.tableView.indexPathForSelectedRow
            addEditViewController.account = fetchedResultsController.objectAtIndexPath(indexPath!) as? Account
            addEditViewController.saveActionType = false
        } else if segue.identifier == Constants.addAccountSegue {
            addEditViewController.saveActionType = true
        }
    }
    
    
}
