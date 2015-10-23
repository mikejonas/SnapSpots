//
//  ImageFileController.swift
//  SnapSpots
//
//  Created by Mike Jonas on 10/20/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import UIKit
import AmazonS3RequestManager


class ImageFileController: NSObject {
    
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    private let defaults = NSUserDefaults.standardUserDefaults()
    private let amazonS3Manager = AmazonS3RequestManager(bucket: "snapspots", region: .USWest1, accessKey: "AKIAJY3DSCPSXTXFV6MQ", secret: "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")
    
    
    func saveImageRemotely(fileName:String, completion:(isSuccess:Bool) ->()) {
        let path = NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(fileName)
        
        amazonS3Manager.putObject(path, destinationPath: "images/\(fileName)").responseS3Data { (response) -> Void in
            if response.result.isSuccess {
                print("\(fileName) saved locally! Now removing it from the queue")
                self.removeFromImageQueue(fileName)
                completion(isSuccess: true)
            } else {
                completion(isSuccess: false)
                print(response.result.error)
            }
        }
        
    }
    
    func retrieveImageRemotely(fileName:String) {
        
        amazonS3Manager.getObject("images/\(fileName)").responseS3Data { (response) -> Void in
            if response.result.isSuccess {
                print("SUCCESS")
            } else {
                print(response.result.error)
            }

            let path = NSURL(fileURLWithPath: self.documentsPath).URLByAppendingPathComponent(fileName)
            if let data = response.data {
                let result = data.writeToURL(path, atomically: true)
                print("image Saved?: \(result)")
            } else {
                print(response.result.error)
            }
        }
    }
    
    
    
    
    func saveImagesLocally(images:[UIImage], imagePaths:[String]) {
        for (i, image) in images.enumerate() {
            let path = NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(imagePaths[i])
            if let jpgImageData = UIImageJPEGRepresentation(image, 0.4) {
                let result = jpgImageData.writeToURL(path, atomically: true)
                if result == true {
                    addToImageUploadQueue(imagePaths[i])
                    saveImageRemotely(imagePaths[i], completion: { (isSuccess) -> () in
                        print("IS SUCCESS????? \(isSuccess)")
                    })
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
    
    func deleteImageRemotely(fileName:String) {
        amazonS3Manager.deleteObject("images/\(fileName)")
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
        }
        
    }
}
