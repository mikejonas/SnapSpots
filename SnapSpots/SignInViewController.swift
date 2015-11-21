//
//  SignInViewController.swift
//  SnapSpots
//
//  Created by Mike Jonas on 11/12/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signInButtonTapped(sender: UIButton) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        signInUser(username!, password: password!)
    }
    
    @IBAction func closeButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func validateUsername() {
        
    }
    func validatePassword() {
        
    }
    func validateEmail() {
        
    }
    
    func signInUser(username:String, password:String) {
        let ref = Firebase(url: "https://snapspot.firebaseio.com")
        
        ref.authUser(username, password: password,
            withCompletionBlock: { error, authData in
                if error != nil {
                    print("ERROR \(error)")
                } else {
                    self.dismissViewControllerAnimated(false, completion: nil)
                    print("Logged in")
                }
        })
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
