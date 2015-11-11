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
    
    private let amazonS3Manager = AmazonS3RequestManager(bucket: "snapspots", region: .USWest1, accessKey: "AKIAJY3DSCPSXTXFV6MQ", secret: "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")
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    private let defaults = NSUserDefaults.standardUserDefaults()
    private var imageDownloadQueue:[String] = []
    private var isUploadingImages = false
    private var isDownloadingImages = false
    
    
    
    func deleteImages(imageFileNames:[String]?) {
        if let imageFileNames = imageFileNames {
            let fileManager = NSFileManager.defaultManager()
            for imageFileName in imageFileNames {
                let path = NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(imageFileName)
                do {
                    try fileManager.removeItemAtURL(path)
                    deleteImageFromCloud(imageFileName)
                    removeFromImageUploadQueue(imageFileName)
                } catch {
                    print("IMAGE NOT DELETED")
                }
            }
        }
    }
    

}

////////////////////////////////////////////////
//Handle downloads
////////////////////////////////////////////////
extension ImageFileController {
    func saveAllImagesFromCloudToApp() {
        if (isDownloadingImages) {
            return
        } else {
            isDownloadingImages = true
        }
        
        if imageDownloadQueue.count > 0 {
            print("IMAGE Download QUEUE COUNT: \(imageDownloadQueue.count), \(isDownloadingImages)")
            saveImageFromCloudToApp(imageDownloadQueue[0], completion: { (isSuccess) -> () in
                if isSuccess {
                    print("saved")
                } else {
                    print("error")
                }
                self.isDownloadingImages = false
                self.saveAllImagesFromCloudToApp()
            })

        }
        self.isDownloadingImages = false
        return
        
    }
    
    func saveImageFromCloudToApp(fileName:String, completion:(isSuccess:Bool) ->()) {
//        amazonS3Manager.getObject("images/\(fileName)").responseS3Data { (response) -> Void in
//            if response.result.isSuccess {
//                let path = NSURL(fileURLWithPath: self.documentsPath).URLByAppendingPathComponent(fileName)
//                if let data = response.data {
//                    let result = data.writeToURL(path, atomically: true)
//                    //?? Might need to move this into removeFromImageDownloadQueue()
//                    self.removeFromImageDownloadQueue(fileName)
//                    completion(isSuccess: true)
//                    print("image Saved?: \(result) \(fileName)")
//                } else {
//                    print("Error getting \(fileName): \(response.result.error)")
//                    completion(isSuccess: false)
//                }
//            } else {
//                print("Error getting \(fileName): \(response.result.error)")
//                
//            }
//        }
    }
    
    func saveImageToApp(imageData:NSData, imagePath:String, completion:(isSuccess:Bool) ->() ) {
        let url = NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(imagePath)
        let isSuccess = imageData.writeToURL(url, atomically: true)
        completion(isSuccess: isSuccess)
    }
    
    func appendToImageDownloadQueue(fileNames:[String]) {
        do {
            let fileList = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsPath)
            for fileName in fileNames {
                if !fileList.contains(fileName) {
                    imageDownloadQueue.append(fileName)
                } else {
                    
                }
            }
            saveAllImagesFromCloudToApp()
        } catch {
            
        }
        print("Image download queue \(imageDownloadQueue)")
    }
    
    func removeFromImageDownloadQueue(fileName:String) {
        if let index = imageDownloadQueue.indexOf(fileName) {
            imageDownloadQueue.removeAtIndex(index)
        } else {
            print("IMAGE DOWNLOAD QUEUE: \(imageDownloadQueue)")
            print("CAN'T FIND IMAGE: \(fileName) TO REMOVE")
        }
    }

    
    //Not in use
    func deleteImageFromCloud(fileName:String) {
        amazonS3Manager.deleteObject("images/\(fileName)").responseS3Data { (response) -> Void in
            if response.result.isSuccess {
                self.removeImageFromDeleteQueue(fileName)
            }
        }
    }
    
}

////////////////////////////////////////////////
//Handle Uploads
////////////////////////////////////////////////
extension ImageFileController {
    
    
    func saveAllImagesFromAppToCloud() {
        if (isUploadingImages == true ) {
            print("STOP!!!! isUploadingImages \(isUploadingImages)")
            return
        } else {
            print("GO!!!!! isUploadingImages \(isUploadingImages)")
        }
        isUploadingImages = true
        
        if var imageUploadQueue = defaults.objectForKey("imageUploadQueue") as? [String] {
            if imageUploadQueue.count > 0 {
                print("IMAGE UPLOAD QUEUE COUNT: \(imageUploadQueue.count)")
                
                saveImageFromAppToCloud(imageUploadQueue[0], completion: { (isSuccess) -> () in
                    if isSuccess {
                        // nope??
                        print("uploaded \(imageUploadQueue[0])!")
                    } else {
                        print("error")
                    }
                    self.isUploadingImages = false
                    self.saveAllImagesFromAppToCloud()
                })
            } else {
                self.isUploadingImages = false
                return
            }
        }
    }
    
    func saveImageFromAppToCloud(fileName:String, completion:(isSuccess:Bool) ->()) {
        let path = NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(fileName)
        amazonS3Manager.putObject(path, destinationPath: "images/\(fileName)").responseS3Data { (response) -> Void in
            if (response.result.isSuccess) {
                self.removeFromImageUploadQueue(fileName)
            }
            completion(isSuccess: response.result.isSuccess)
        }
    }
    
    func appendToImageUploadQueue(fileName:String) {
        if var imageUploadQueue = defaults.objectForKey("imageUploadQueue") as? [String] {
            imageUploadQueue.append(fileName)
            defaults.setObject(imageUploadQueue, forKey: "imageUploadQueue")
        } else {
            defaults.setObject([fileName], forKey: "imageUploadQueue")
        }
    }
    

    private func removeFromImageUploadQueue(fileName:String) {
        if var imageUploadQueue = defaults.objectForKey("imageUploadQueue") as? [String] {
            if let index = imageUploadQueue.indexOf(fileName) {
                imageUploadQueue.removeAtIndex(index)
            } else {
                print("CAN'T FIND IMAGE \(fileName) TO REMOVE")
            }
            defaults.setObject(imageUploadQueue, forKey: "imageUploadQueue")
            
            print("IMAGE UPLOAD QUEUE: \(imageUploadQueue)")
        }
    }
    
    func appendImageToDeleteQueue(fileName:String) {
        if var deleteQueue = defaults.objectForKey("deleteQueue") as? [String] {
            deleteQueue.append(fileName)
            defaults.setObject(deleteQueue, forKey: "deleteQueue")
        } else {
            defaults.setObject([fileName], forKey: "deleteQueue")
        }
    }
    private func removeImageFromDeleteQueue(fileName:String) {
        if var deleteQueue = defaults.objectForKey("deleteQueue") as? [String] {
            if let index = deleteQueue.indexOf(fileName) {
                deleteQueue.removeAtIndex(index)
            }
            defaults.setObject(deleteQueue, forKey: "deleteQueue")
        }
    }
    
    
    
    
    
    
}