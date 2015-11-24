//
//  SaveSpotTableViewController.swift
//  SnapSpots
//
//  Created by Mike Jonas on 11/21/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import UIKit
import Firebase

class SaveSpotTableViewController: UITableViewController {
    
    var spotComponents = SpotComponents()
    var listGroups:[SpotGroupComponents] = []
    var selectedSpotGroups:[SpotGroupComponents] = []
    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    
    override func viewWillAppear(animated: Bool) {
        if let userid = ref.authData {
            ref.childByAppendingPath("users_groups/\(userid.uid)").observeSingleEventOfType(.ChildAdded, withBlock: { snapshot in
                //For each
                let groupKey = snapshot.key
                self.ref.childByAppendingPath("groups/\(groupKey)/name").observeSingleEventOfType(.Value, withBlock: { snapshot in
                    let group = SpotGroupComponents(groupName: snapshot.value as! String, groupID: groupKey as String)
                    self.listGroups.append(group)
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.setEditing(true, animated: true)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your groups"
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listGroups.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupsCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = listGroups[indexPath.row].groupName
        return cell
    }
    
    


    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle(rawValue: 3)!
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedGroup = self.listGroups[indexPath.row]
        selectedSpotGroups.append(selectedGroup)
        
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let deSelectedGroup = self.listGroups[indexPath.row]
        if let itemToRemove = selectedSpotGroups.map({ $0.groupID }).indexOf(deSelectedGroup.groupID) {
            selectedSpotGroups.removeAtIndex(itemToRemove)
        }
        print(selectedSpotGroups)
        
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(false, completion: nil)
        for group in selectedSpotGroups {
            saveNewSpot(spotComponents, group: group)
            
        }

    }
    
    

}
