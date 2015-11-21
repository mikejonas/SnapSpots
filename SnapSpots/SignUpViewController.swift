//
//  SignUpViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 10/13/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import UIKit
import Firebase
import FontAwesome_swift

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonTapped(sender: UIButton) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        createUser(username!, password: password!, email: email!)
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
    
    func createUser(username:String, password:String, email:String) {
        let ref = Firebase(url: "https://snapspot.firebaseio.com")
        
        ref.createUser(email , password: password,
            withValueCompletionBlock: { error, result in
                if error != nil {
                    print("ERROR \(error)")
                } else {
                    if let uid = result["uid"] as? String {
                        let newGroupRef = ref.childByAppendingPath("groups").childByAutoId()
                        let newGroupKey = newGroupRef.key
                        let updatedData =  [
                            "users/\(uid)" : ["username": username],
                            "groups/\(newGroupKey)/" : ["name" : username],
                            "groups_members/\(newGroupKey)/owner" : [uid : true],
                            "users_groups/\(uid)" : [newGroupKey : true]
                        ]
                        
                        ref.updateChildValues(updatedData, withCompletionBlock: { (error, ref) -> Void in
                            
                            ref.authUser(email, password: password,
                                withCompletionBlock: { error, authData in
                                    if error != nil {
                                        print("ERROR \(error)")
                                    } else {
                                        self.dismissViewControllerAnimated(false, completion: nil)
                                        print("Logged in")
                                    }
                            })
                            
                        })
                        

                        
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }
                }
        })
    }
    
    func setupDefaultGroup(groupName:String, userName:String) {
        let ref = Firebase(url: "https://snapspot.firebaseio.com")
        let groupRef = ref.childByAppendingPath("groups").childByAutoId();
        let groupMembers = groupRef.childByAppendingPath("members");
        groupRef.setValue([
            "name": groupName,
        ]);
        groupMembers.setValue([
            userName: true
        ])
        
        let userRef = ref.childByAppendingPath("users").childByAppendingPath(userName);
        let userGroupsRef = userRef.childByAppendingPath("groups")
        userGroupsRef.setValue([
            
        ])
        
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
