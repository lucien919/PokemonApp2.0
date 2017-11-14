//
//  LoginViewController.swift
//  PokemonApp2.0
//
//  Created by Mac on 11/13/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper
import LocalAuthentication

class LoginViewController: UIViewController {
    @IBOutlet weak var userName:UITextField!
    @IBOutlet weak var password:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Background"))
        
        userName.delegate = self
        password.delegate = self
        
        guard let email = UserDefaults.standard.object(forKey: Constants.kUserNameKey) as? String else{return}
        userName.text = email
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userName.becomeFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    fileprivate func loginToFirebase(){
        LoginInfo.shared.sharedAuth.signIn(withEmail: userName.text!, password: password.text!){
            (user, error) in
            guard error == nil else{
                
                return
            }
            guard let user = user else{return}
            guard let email = user.email else{return}
            LoginInfo.shared.user = User(email: email, uid: user.uid)
            let userDefaults = UserDefaults.standard
            userDefaults.set(email, forKey: Constants.kUserNameKey)
            //ask if user wants to use touch id
            //check for his fingerprint in the system
            //KeychainWrapper.standard.set(self.password.text!, forKey: Constants.kPassKey)
        }
        
        guard LoginInfo.shared.isLoggedIn else{return}
        performSegue(withIdentifier: "ToPokemonAfterLoginSegue", sender: self)
    }
    
    private func isTouchIDEnabled()->Bool{
        let context = LAContext()
        var error:NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        guard error == nil else {return false}
        return true
    }
    
}

typealias TextFieldFunctions = LoginViewController
extension TextFieldFunctions:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField === userName){
            textField.resignFirstResponder()
            //textField.becomeFirstResponder()
            guard let text = textField.text else{return false}
            guard text.isValidEmail() else {
                
                let alert = UIAlertController(title: "Whoops", message: "Email is not in correct format", preferredStyle: .alert)
                let action = UIAlertAction(title: "Okay", style: .default)
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
                return false
            }
            password.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            //password.becomeFirstResponder()
            guard let text = textField.text else{return false}
            guard text.isValidPassword() else{
                let alert = UIAlertController(title: "No No No", message: "Password needs to contain at least 6 total character with one being a number", preferredStyle: .alert)
                let action = UIAlertAction(title: "Got it", style: .default)
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
                
                return false
            }
            
        }
        
        self.loginToFirebase()
        return false
        
    }
    
}
