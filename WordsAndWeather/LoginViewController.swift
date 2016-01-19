//
//  LoginViewController.swift
//  WordsAndWeather
//
//  Created by Franks, Kent on 11/5/15.
//  Copyright © 2015 Franks, Kent. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var useTouchIDButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherIconLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    
    // MARK: - Navigation vars
    var loginSuccessful = false
    var createdLogin = false
    var loginExists = false
    var touchIDAvailable = false
    var attemptManualLogin = false
    var attemptTouchIDLogin = false

    // MARK: - Core Data vars
    var persistenceController: PersistenceController?
    var mainContext: NSManagedObjectContext?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        attemptManualLogin = false
        attemptTouchIDLogin = false
        
        if let persistenceController = persistenceController {
            mainContext = persistenceController.mainMoc
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userLoginExists = defaults.objectForKey(Constants.userIDExists) as! Bool? {
            loginExists = userLoginExists
            if loginExists {
                loginButton.setTitle("Login", forState: UIControlState.Normal)
                loginButton.enabled = false
                deleteButton.hidden = false
            } else {
                loginButton.setTitle("Create Login", forState: UIControlState.Normal)
                loginButton.enabled = false
                deleteButton.hidden = true
            }
        } else {
            loginButton.setTitle("Create Login", forState: UIControlState.Normal)
            loginButton.enabled = false
            deleteButton.hidden = true
        }
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "textFieldHasChanged",
            name: UITextFieldTextDidChangeNotification,
            object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        createdLogin = false
        LoginViewModel.getWeather() {
            returnedValue -> Void in
            print(returnedValue)
            self.cityLabel.text = LoginViewModel.city
            if LoginViewModel.mainWeather == "Rain" {
                self.weatherIconLabel.text = "☔️"
            } else if LoginViewModel.mainWeather == "Sun" {
                self.weatherIconLabel.text = "☀️"
            } else if LoginViewModel.mainWeather == "Clouds" {
                self.weatherIconLabel.text = "☁️"
            } else if LoginViewModel.mainWeather == "Snow" {
                self.weatherIconLabel.text = "❄️"
            } else if LoginViewModel.mainWeather == "Mist" {
                self.weatherIconLabel.text = "💧"
            }else {
                self.weatherIconLabel.text = "🌄"
            }
            self.descriptionLabel.text = LoginViewModel.weatherDescription
            self.currentTempLabel.text = String(LoginViewModel.currentTemp!) +  "\u{00B0}"
        }
    }
    
    // MARK: - Actions
    @IBAction func loginAction(sender: AnyObject) {
        attemptManualLogin = true
        if loginExists {
            guard LoginViewModel.loginWithUsernamePassword(usernameTextField.text!, password: passwordTextField.text!) else {
                showAlertController(Constants.manualLoginUnsuccessful)
                return
            }
            loginSuccessful = true
        } else {
            guard LoginViewModel.createLogin(usernameTextField.text!, password: passwordTextField.text!) else {
                print("failed to create login")
                // TODO: Handle failure here
                return
            }
            loginButton.setTitle("Login", forState: UIControlState.Normal)
            deleteButton.hidden = false
            loginExists = true
            createdLogin = true
        }
    }
    
    @IBAction func deleteLoginAction(sender: AnyObject) {
        guard LoginViewModel.deleteLogin() else {
            print("failed to delete login")
            // TODO: Handle failure here
            return
        }
        deleteButton.hidden = true
        usernameTextField.text = ""
        passwordTextField.text = ""
        loginButton.setTitle("Create Login", forState: UIControlState.Normal)
        loginButton.enabled = false
        loginExists = false
    }
    
    @IBAction func useTouchIDAction(sender: AnyObject) {
        attemptTouchIDLogin = true
        LoginViewModel.loginWithTouchID() {
            returnedValue -> Void in
            self.loginSuccessful = returnedValue.isSuccessful
            self.touchIDAvailable = returnedValue.isTouchIDAvailable
            if self.loginSuccessful {
                self.performSegueWithIdentifier(Constants.accountsTableSegue, sender: self)
            }
        }
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
            loginAction(loginButton)
        }
        return false
    }
    
    func textFieldHasChanged() {
        if usernameTextField.text!.characters.count > 0 && passwordTextField.text!.characters.count > 0 {
            loginButton.enabled = true
        } else {
            loginButton.enabled = false
        }
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let accountsTableViewController = navigationController.topViewController as! AccountsTableViewController
        accountsTableViewController.persistenceController = self.persistenceController
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "accountsTableSegue" {
            if loginSuccessful {
                return true
            } else if createdLogin {
                return false
            } else {
                showAlertController(Constants.manualLoginUnsuccessful)
                return false
            }
        }
        return true
    }
    
    // MARK: - AlertView
    func showAlertController(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
