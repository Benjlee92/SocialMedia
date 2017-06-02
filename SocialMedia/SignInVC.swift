//
//  ViewController.swift
//  SocialMedia
//
//  Created by Ben on 5/23/17.
//  Copyright © 2017 Ben. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var logInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("Ben: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookButtontapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Ben: unable to authenticate with facebook - \(error)")
            } else if result?.isCancelled == true {
                print("Ben: user cancelled facebook authentication")
            } else {
                print("Ben: successfully authenticated with facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuthenticate(credential)
            }
        }
    }
    
    func firebaseAuthenticate(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Ben: unable to authenticate with firebase - \(error)")
            } else {
                print("Ben: sucessfully authenticated with firebase")
                if let user = user {
                    let userData = ["provider" : user.providerID]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    @IBAction func logInTapped(_ sender: Any) {
        if let email = emailField.text, let pwrd = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwrd, completion: { (user, error) in
                if error == nil {
                    print("Ben: email user authenticated with firebase")
                    
                    if let user = user {
                        let userData = ["provider" : user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwrd, completion: { (user, error) in
                        if error != nil {
                            print("Ben:  firebase user email unable to authenticate with firebase - \(error)")
                        } else {
                            print("Ben: successfully autenticated with firebase")
                            
                            if let user = user {
                                let userData = ["provider" : user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
            
        }
    }
    
    func completeSignIn(id : String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Ben: data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }

}

