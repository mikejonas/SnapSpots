//
//  ListSpotsCollectionViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/27/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import Kingfisher

class ListSpotsCollectionViewController: UICollectionViewController {

    let reuseIdentifier = "SpotCollectionCell"

    var parentNavigationController : UINavigationController?
    var dateFormatter = NSDateFormatter()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.collectionView!.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewSpotSegue" {
            let destinationVC = segue.destinationViewController as! ViewSpotViewController
            let cell = sender as! UICollectionViewCell

            let indexPath = self.collectionView!.indexPathForCell(cell)
            if let key = spots[indexPath!.row].key {
                destinationVC.postKey = key
            }
        }
        
    }

    // Full Screen Shot function. Hope this will work well in swift.
    
    func screenShot() -> UIImage {
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!) //??? added the !
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenShot
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return spots.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:SpotCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SpotCollectionCell
//        print(self.spots[indexPath.row])
        
        let city = spots[indexPath.row].addressComponents.locality
        let city2 = spots[indexPath.row].addressComponents.subLocality
        
        if city != nil {
            cell.locationLabel.text = city
        } else if city2 != nil {
            cell.locationLabel.text = city2
        }
        if spots[indexPath.row].images.count > 0 {        
            if let imagePath = spots[indexPath.row].images[0].path {
                if let image = retrieveImageLocally(imagePath) {
                    cell.imageThumbnail.image = image
                } else {
                    let URL = NSURL(string: "https://s3-us-west-1.amazonaws.com/snapspots/images/\(imagePath)")!
                    cell.imageThumbnail.kf_setImageWithURL(URL,
                        placeholderImage: nil,
                        optionsInfo: nil,
                        progressBlock: { (receivedSize, totalSize) -> () in
//                            print("Download Progress: \(receivedSize)/\(totalSize)")
                        },
                        completionHandler: { (image, error, cacheType, imageURL) -> () in
//                            print("error: \(error)")
//                            print("cacheType \(cacheType)")
//                            print("imageURL \(imageURL)")
                        }
                    )
                    
                }
            } else {
                //No Images found?
                cell.imageThumbnail.image = nil
            }
        }
        
        
        if let timeStamp = spots[indexPath.row].date {
            dateFormatter.dateFormat = "MMM dd"
            let monthDay = dateFormatter.stringFromDate(timeStamp).componentsSeparatedByString(" ")
            
            cell.monthLabel.text = monthDay[0]
            cell.dayLabel.text = monthDay[1]
        }

        // Configure the cell
        return cell
    }
    
    

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            performSegueWithIdentifier("ViewSpotSegue", sender: cell)
        } else {
            print("Error indexPath is not on screen: this should never happen.")
        }
        
    }
    
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
