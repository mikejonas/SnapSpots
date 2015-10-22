//
//  ImageUtil.swift
//  SnapSpot2
//
//  Created by Mike Jonas on 4/16/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import AmazonS3RequestManager
import Alamofire

class ImageUtil {
    class func cropVerticalImageToSquare(image:UIImage) -> UIImage {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let navbarHeight:CGFloat = 64
        let posX:CGFloat = (image.size.width / screenWidth) * navbarHeight
        let posY:CGFloat = 0
        
        let rect: CGRect = CGRectMake(posX, posY, image.size.width, image.size.width)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, rect)!
        let croppedImage: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        return croppedImage
    }
    
    class func scaleImageTo(newWidth newWidth:CGFloat, image:UIImage) -> UIImage {
        let newHeight = (image.size.height/image.size.width) * newWidth
        let newSize = CGSizeMake(newWidth, newHeight)
        var resizedImage:UIImage
        
        // Resize the image
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    class func downloadImage() {
        let amazonS3Manager = AmazonS3RequestManager(bucket: "snapspots", region: .USWest1, accessKey: "AKIAJY3DSCPSXTXFV6MQ", secret: "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")

        // We need just to get the documents folder url

        let dir: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        amazonS3Manager.getObject("images/test.jpg").responseS3Data { (response) -> Void in
            
            if response.result.isSuccess {
                print("SUCCESS")
            } else {
                print(response.result.error)
            }
//            let path = NSURL(fileURLWithPath: String(dir)).URLByAppendingPathComponent("asdf.jpg")
//            if let data = response.data {
//                let result = data.writeToURL(path, atomically: true)
//                print("image Saved?: \(result)")
//            } else {
//                print(response.result.error)
//            }
        }

        do {
            let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(dir, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            print(directoryContents)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func saveImageData(data:NSData, fileName:String){
        if let dirs:[String] = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as [String] {
            let dir = dirs[0] //documents directory
                let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(fileName)
                let result = data.writeToURL(path, atomically: true)
                print("image Saved?: \(result)")

        }
        
    }
}
