//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Reham on 27/12/2018.
//  Copyright © 2018 Reham. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        
        guard emailTextField.text != "", passwordTextField.text != "" else {
            debugTextLabel.text = "Email or Password Empty."
            return
        }

        setUIEnabled(false)
        
        APICalls.shared.login(email: emailTextField.text!, password: passwordTextField.text!) { (message, result, error) in
            guard error != nil else{
                performUIUpdatesOnMain{
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = message
                }
             
               return
            }
            guard result == true else {
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = message
                }
              
                return
            }
        }
        self.completeLogin()

        
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let app = UIApplication.shared
        app.open(URL(string: "https://auth.udacity.com/sign-up")!, options: [:], completionHandler: nil)

    }
    
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "UdacityTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(emailTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)
private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool){
        
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        debugTextLabel.isEnabled = enabled
        loginButton.isEnabled = enabled
        signUpButton.isEnabled = enabled
        
        // adjust login button alpha
        loginButton.alpha = enabled ? 1.0 : 0.5
        
    }
}

// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


