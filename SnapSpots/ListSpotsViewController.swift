//
//  ListSpotsViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/26/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import Firebase

var spots:[SpotComponents] = []

class ListSpotsViewController: UIViewController {

    var ref: Firebase!
    var refPaths:[String] = []
    
    var pageMenu : CAPSPageMenu?
    let listSpotsCollectionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListSpotsCollectionViewController") as! ListSpotsCollectionViewController
    let ListSpotsTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListSpotsTableViewController") as! ListSpotsTableViewController
    let ListSpotsMapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListSpotsMapViewController") as! ListSpotsMapViewController
    
    var buttonImage = UIImage(named: "Nav Hashtag")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    


    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.listSpotsCollectionVC.collectionView!.reloadData()

        if let userid = ref.authData {
            //Get listing of users groups
            let usersGroupsPath = "users_groups/\(userid.uid)"
            
            if !self.refPaths.contains(usersGroupsPath) {
                self.refPaths.append(usersGroupsPath)
                ref.childByAppendingPath(usersGroupsPath).observeSingleEventOfType(.ChildAdded, withBlock: { snapshot in

                    //For each group, get list of spots
                    let groupKey = snapshot.key
                    let groupsSpotsPath = "groups_spots/\(groupKey)"
                    if !self.refPaths.contains(groupsSpotsPath) {
                        self.refPaths.append(groupsSpotsPath)
                        self.ref.childByAppendingPath(groupsSpotsPath).observeEventType(.ChildAdded, withBlock: { snapshot in
                            
                            //For each spot in group, get the spot details
                            print("SNAPSHOT KEY:    spots/\(snapshot.key)")
                            self.ref.childByAppendingPath("spots/\(snapshot.key)").observeSingleEventOfType(.Value, withBlock: { snapshot in
                                
                                //for each spot, append to array and then reload data
                                print("KEY:: \(snapshot.key)")
                                print("REF:: \(snapshot.ref)")
                                
                                spots.insert(convertFirebaseObjectToSpotComponents(snapshot), atIndex: 0)
                                self.listSpotsCollectionVC.collectionView!.reloadData()
                            })

                        })
                    }
                    
    //                groupsSpotsRef.queryOrderedByChild("date").observeEventType(.ChildRemoved, withBlock: { snapshot in
    //                    if let i = spots.indexOf({$0.key == snapshot.key}) {
    //                        spots.removeAtIndex(i)
    //                    }
    //                    self.listSpotsCollectionVC.collectionView!.reloadData()
    //                })
    //                
                    
                })
            }
        }

        
        
//        ref.observeEventType(.Value, withBlock: { snapshot in
//            print(snapshot.value)
//        })

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Firebase
        ref = Firebase(url:"https://snapspot.firebaseio.com")
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        var controllerArray : [UIViewController] = []
        

        listSpotsCollectionVC.title = String.fontAwesomeIconWithName(.ThLarge)
        controllerArray.append(listSpotsCollectionVC)
        
        ListSpotsTableVC.title = String.fontAwesomeIconWithName(.Navicon)
        controllerArray.append(ListSpotsTableVC)
        
        ListSpotsMapVC.title = String.fontAwesomeIconWithName(.MapMarker)
        controllerArray.append(ListSpotsMapVC)

        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .MenuItemSeparatorWidth(0),
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .ViewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .BottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
            .SelectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .MenuMargin(20.0),
            .MenuHeight(37.0),
            .SelectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .UnselectedMenuItemLabelColor(UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0)),
            .MenuItemFont(UIFont.fontAwesomeOfSize(21)),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorRoundEdges(false),
            .SelectionIndicatorHeight(2.0),
            .MenuItemSeparatorPercentageHeight(0),
            .ScrollAnimationDurationOnMenuItemTap(100)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        // Optional delegate
        pageMenu!.delegate = self
        
        self.view.addSubview(pageMenu!.view)
        
    }
    

    
    override func viewDidAppear(animated: Bool) {
//        listSpotsCollectionVC.collectionViewTestReloadData()
        
        let hashtagString = (Globals.variables.filterSpotsHashtag).joinWithSeparator(". #")
        print(hashtagString)
        if hashtagString == "" {
            self.navigationController?.navigationBar.topItem?.title = "Spots"
        } else {
            self.navigationController?.navigationBar.topItem?.title
            self.navigationController?.navigationBar.topItem?.title = "#\(hashtagString)"
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        for refPath in refPaths {
            print(refPath)
//            ref.childByAppendingPath(refPath).removeAllObservers()
        }
//        refPaths = []
//        spots = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftBarButtonItemTapped(sender: UIBarButtonItem) {
        pageController.goToPreviousVC()
//        pageMenu!.moveToPage(2)
    }
    @IBAction func rightBarButtonItemTapped(sender: UIBarButtonItem) {
        pageController.goToNextVC()
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

extension ListSpotsViewController: CAPSPageMenuDelegate {
    func willMoveToPage(controller: UIViewController, index: Int) {
        if index == 0 {
            print("0")
        }
        if index == 1 {
            print("1")
        }
        if index == 2 {
            print("2")
        }
    }
}
