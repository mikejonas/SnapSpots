//
//  ImageFileController.swift
//  SnapSpots
//
//  Created by Mike Jonas on 10/20/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import UIKit

class ImageFileController: NSObject {
    
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let defaults = NSUserDefaults.standardUserDefaults()

    func saveImagesLocally(images:[UIImage], imagePaths:[String]) {
        for (i, image) in images.enumerate() {
            let path = NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(imagePaths[i])
            if let jpgImageData = UIImageJPEGRepresentation(image, 0.4) {
                let result = jpgImageData.writeToURL(path, atomically: true)
                if result == true {
                    addToImageUploadQueue(imagePaths[i])
                }
            }
        }
    }
    
    func deleteImagesLocally(imageFileNames:[String]?) -> [String] {
        var deletedImages:[String] = []
        if let imageFileNames = imageFileNames {
            let fileManager = NSFileManager.defaultManager()
            for imageFileName in imageFileNames {
                let path = NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(imageFileName)
                do {
                    try fileManager.removeItemAtURL(path)
                    deletedImages.append(imageFileName)
                    removeFromImageQueue(imageFileName)
                } catch {
                    print("IMAGE NOT DELETED")
                }
            }
        }
        return deletedImages
    }
    
    private func addToImageUploadQueue(fileName:String) {
        if var imageUploadQueue = defaults.objectForKey("imageUploadQueue") as? [String] {
            // add to the words array and then
            imageUploadQueue.append(fileName)
            defaults.setObject(imageUploadQueue, forKey: "imageUploadQueue")
        } else {
            defaults.setObject([fileName], forKey: "imageUploadQueue")
        }
    }

    private func removeFromImageQueue(fileName:String) {
        if var imageUploadQueue = defaults.objectForKey("imageUploadQueue") as? [String] {
            print("START DELETING IMAGES")
            // add to the words array and then
            if let i = imageUploadQueue.indexOf(fileName) {
                imageUploadQueue.removeAtIndex(i)
            } else {
                print("CAN'T FIND IMAGE \(fileName) TO REMVOVE")
            }
            defaults.setObject(imageUploadQueue, forKey: "imageUploadQueue")
        
            print("IMAGE UPLOAD QUEUE: \(imageUploadQueue)")
        } else {
            print("????")
        }
        
    }
    
    
    func saveImageRemotely() {
        
    }
    
    func deleteImageRemotely() {
        
    }
}
