//
//  LoginViewController.swift
//  ChessFirebase
//
//  Created by hyperactive on 23/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    @IBOutlet weak var EmailTF: UITextField!
    @IBOutlet weak var PasswordTF: UITextField!
    @IBOutlet weak var LoginB: UIButton!
    @IBOutlet weak var ErrorL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }

    func setUpElements() {
        ErrorL.isHidden = true
        Utilities.editButton(LoginB)
//        navigationController?.navigationBar.isHidden = true
        self.setBackgroundImage("chess")
    }
    
    func validateFields() -> String? {
        
        //check if all fields are filled in
        if  EmailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || PasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all the fields."
        }
        
        return nil
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // validate textfields
        let error = validateFields()
        
        // check the error
        if let error = error {
            showError(err: error)
        } else {
            //get clean info from fields
            let email = EmailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = PasswordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            isUserLoggedIn(email: email) { (result, data) in
        
                let username = data!["username"] as! String
                self.logInUserWith(email, password, username)
                
            }
        }
    }
    
    func logInUserWith(_ email : String,_ password: String, _ username: String) {
        Auth.auth().signIn(withEmail: email, password: password) {
            (result, err) in
            
            if let err = err {
                self.showError(err: err.localizedDescription)
            } else {
                self.transitionToLobby(username)
            }
        }
    }
    
    func isUserLoggedIn(email: String, _ completion: @escaping (_ res: Bool?, _ data: [String : Any]?) -> Void ) {
        
        let db = Firestore.firestore()
        let docRef = db.collection("users")
        
        docRef.document(email).getDocument { (documentSnapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil,nil)
                return
            }
            guard let data = documentSnapshot?.data() else {
                completion(nil,nil)
                return
            }
            let result = data["isActive"] != nil && data["isActive"] as! Bool
            completion(result, data) //data of current user
        }
    }
    
    func showError(err: String) {
        ErrorL.text = err
        ErrorL.isHidden = false
    }
    
    func transitionToLobby(_ username: String) {
        guard let vc = storyboard?.instantiateViewController(identifier: Constants.Storyboard.lobbyViewController) as? LobbyTableViewController else { return }
        vc.username = username
        self.navigationController?.show(vc, sender: nil)
    }
}
