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
        
        let defaults = UserDefaults.standard
        if let userLoginExists = defaults.object(forKey: Constants.userIDExists) as! Bool? {
            loginExists = userLoginExists
            if loginExists {
                loginButton.setTitle("Login", for: UIControlState())
                loginButton.isEnabled = false
                deleteButton.isHidden = false
            } else {
                loginButton.setTitle("Create Login", for: UIControlState())
                loginButton.isEnabled = false
                deleteButton.isHidden = true
            }
        } else {
            loginButton.setTitle("Create Login", for: UIControlState())
            loginButton.isEnabled = false
            deleteButton.isHidden = true
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LoginViewController.textFieldHasChanged),
            name: NSNotification.Name.UITextFieldTextDidChange,
            object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
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
    @IBAction func loginAction(_ sender: AnyObject) {
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
            loginButton.setTitle("Login", for: UIControlState())
            deleteButton.isHidden = false
            loginExists = true
            createdLogin = true
        }
    }
    
    @IBAction func deleteLoginAction(_ sender: AnyObject) {
        guard LoginViewModel.deleteLogin() else {
            print("failed to delete login")
            // TODO: Handle failure here
            return
        }
        deleteButton.isHidden = true
        usernameTextField.text = ""
        passwordTextField.text = ""
        loginButton.setTitle("Create Login", for: UIControlState())
        loginButton.isEnabled = false
        loginExists = false
    }
    
    @IBAction func useTouchIDAction(_ sender: AnyObject) {
        attemptTouchIDLogin = true
        LoginViewModel.loginWithTouchID() {
            returnedValue -> Void in
            self.loginSuccessful = returnedValue.isSuccessful
            self.touchIDAvailable = returnedValue.isTouchIDAvailable
            if self.loginSuccessful {
                self.performSegue(withIdentifier: Constants.accountsTableSegue, sender: self)
            }
        }
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
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
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let accountsTableViewController = navigationController.topViewController as! AccountsTableViewController
        accountsTableViewController.persistenceController = self.persistenceController
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any!) -> Bool {
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
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
}
