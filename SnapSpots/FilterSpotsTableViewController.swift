//
//  FilterSpotsTableViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 9/5/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import Firebase


class FilterSpotsTableViewController: UITableViewController {
    
    var hashTagsArr:[(String, [String])] = []
    var activePaths:[String] = []
    var returnSpotsUtil = Globals.constants.appDelegate.returnSpotsUtil

    
    override func viewWillAppear(animated: Bool) {
        
        self.tableView.reloadData()

    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setEditing(true, animated: true)
        
        
        
        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func leftBarButtonItemTapped(sender: UIBarButtonItem) {
        pageController.goToPreviousVC()
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (returnSpotsUtil?.hashtagsArr.count)!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (returnSpotsUtil?.hashtagsArr[section].1.count)!
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
//        let hashtag = returnSpotsUitl
        cell.textLabel?.text = returnSpotsUtil!.hashtagsArr[indexPath.section].1[indexPath.row].0
        cell.detailTextLabel?.text = "\(returnSpotsUtil!.hashtagsArr[indexPath.section].1[indexPath.row].1)"

        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cellText = cell.textLabel?.text {
            if (Globals.variables.filterSpotsHashtag).contains(String(cellText.characters.dropFirst())) {
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            } else {
                cell.selected = false
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let groupId = returnSpotsUtil?.hashtagsArr[indexPath.section].0.groupId
        let hashtag = returnSpotsUtil?.hashtagsArr[indexPath.section].1[indexPath.row].0
        print("groupId \(groupId)")
        print("hashtag \(hashtag)")
//        returnSpotsUtil?.selectedHashtags.append((groupId, hashtag))
//        Globals.variables.clearFirebaseObservers()
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let deSelectedHashTag = self.hashTagsArr[indexPath.row].0
        if let itemToRemove = Globals.variables.filterSpotsHashtag.indexOf(deSelectedHashTag) {
            Globals.variables.filterSpotsHashtag.removeAtIndex(itemToRemove)
        }
        //        Globals.variables.clearFirebaseObservers()
        
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return returnSpotsUtil?.hashtagsArr[section].0.groupName
    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
    //    func countAndsortArrays(hashtagArrays:[[String]]) -> [(String, Int)] {
    //        var arr:[(String,Int)] = []
    //        var sortedHashtagDict = [String:Int]()
    //
    //        for item in hashtagArrays {
    //            for hashTag in item {
    //                if (sortedHashtagDict[hashTag] != nil) {
    //                    sortedHashtagDict[hashTag] = sortedHashtagDict[hashTag]! + 1
    //                } else {
    //                    sortedHashtagDict[hashTag] = 1
    //                }
    //            }
    //        }
    //        arr = sortedHashtagDict.sort({ (t1, t2) -> Bool in
    //            return t1.1 > t2.1
    //        })
    //
    //        
    //        return arr
    //    }
    //    

    
}
