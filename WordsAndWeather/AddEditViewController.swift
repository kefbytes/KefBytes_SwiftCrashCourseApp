//
//  AddEditViewController.swift
//  SwiftCrashCourseApp
//
//  Created by Franks, Kent on 11/5/15.
//  Copyright © 2015 Franks, Kent. All rights reserved.
//

import UIKit
import CoreData

class AddEditViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI Outlets
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var accountUsernameTextField: UITextField!
    @IBOutlet weak var accountPasswordTextField: UITextField!
    @IBOutlet weak var saveAccountButton: UIButton!
    
    
    // MARK: - Core Data vars
    /* coreDataController was injected from the app delegate */
    var persistenceController: PersistenceController?
    var mainContext: NSManagedObjectContext?
    var account:Account?
    var saveActionType = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coreDataController = persistenceController {
            /* get the main moc from the persistenceController */
            mainContext = coreDataController.mainMoc
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = account {
            hydrateTextFields()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func saveAccountAction(sender: AnyObject) {
        
        let accountName = accountNameTextField.text!
        let accountUsername = accountUsernameTextField.text!
        let accountPassword = accountPasswordTextField.text!
        
        if saveActionType {
            AddEditViewModel.saveAccount(mainContext!, coreDataController: self.persistenceController!, accountName: accountName, userName: accountUsername, password: accountPassword)
        } else {
            AddEditViewModel.updateAccount(mainContext!, coreDataController: self.persistenceController!, accountName: accountName, userName: accountUsername, password: accountPassword)
        }
        
        accountNameTextField.text = ""
        accountUsernameTextField.text = ""
        accountPasswordTextField.text = ""
        dismissKeyboard()
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    // MARK: - Setup UI
    func hydrateTextFields() {
        accountNameTextField.text = account!.accountName!
        accountUsernameTextField.text = account!.username!
        accountPasswordTextField.text = account!.password!
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTag=textField.tag+1;
        let nextResponder=textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
            saveAccountAction(textField)
        }
        return false
    }
    
    
    // MARK: - Keyboard
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
}
