//
//  SignUpViewController.swift
//  ChessFirebase
//
//  Created by hyperactive on 23/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var UserNameTF: UITextField!
    @IBOutlet weak var EmailTF: UITextField!
    @IBOutlet weak var PasswordTF: UITextField!
    @IBOutlet weak var SignUpB: UIButton!
    @IBOutlet weak var ErrorL: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
        
    func setUpElements() {
        ErrorL.isHidden = true
        Utilities.editButton(SignUpB)
//        navigationController?.navigationBar.isHidden = true
        self.setBackgroundImage("chess")
    }
        
        //check fields and validate that data is correct, if everythink is correct
    func validateFields() -> String? {
            
            //check if all fields are filled in
        if UserNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||  EmailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || PasswordTF.text?.trimmingCharacters(in:.whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
            
        let password = PasswordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
        if !Utilities.isPasswordValid(password) {
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
            
        return nil
    }
        
    @IBAction func signUpTapped(_ sender: Any) {
            
        //validate fields
        let error = validateFields()
            
        if let error = error {
            // error is not nil show error massage
            showError(error)
        }
            //create user
        let email = EmailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = PasswordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = UserNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
        Auth.auth().createUser(withEmail: email, password: password) {
            (result, err) in
    
            //check for errors
            if err != nil {
                self.showError("Error creating user")
            } else {
                //create clean data
    
                //User was created
                let db = Firestore.firestore()
                
                db.collection("users").document(email).setData(["username" : username,"email" : email, "uid": result!.user.uid ]) { (error) in
                    if let err = error {
                        self.ErrorL.text = err.localizedDescription
                    }
                self.transitionToLobby(username)
                }
            }
        }
    }
        
    func showError(_ error: String) {
        ErrorL.text = error
        ErrorL.isHidden = false
    }
    
    func transitionToLobby(_ username: String) {
        guard let vc = storyboard?.instantiateViewController(identifier: Constants.Storyboard.lobbyViewController) as? LobbyTableViewController else { return }
        vc.username = username
        self.navigationController?.show(vc, sender: nil)
    }
}
