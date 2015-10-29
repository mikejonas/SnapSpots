//
//  SpotComponents.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/24/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SwiftyJSON
import Firebase

struct SpotComponents: CustomStringConvertible {
    var key: String?
    var user: String?
    var caption: String?
    var hashTags: [String]?
    var images:[ImageComponents] = []
    var addressComponents = SpotAddressComponents()
    var date:NSDate?
    var isSynced:Bool?
    var description: String {
        return "\n caption: \(caption) \n hashTags: \(hashTags) \n images: \(images) \n addressComponents: \(addressComponents)"
    }
}

struct ImageComponents {
    var image:UIImage?
    var path:String?
}

struct SpotAddressComponents: CustomStringConvertible {
    var coordinates: CLLocationCoordinate2D?
    var locality: String? // City
    var subLocality: String? // Also City
    var administrativeArea: String? // State
    var country: String? // Country
    var fullAddress: String?
    var description: String {
        return " coordinates: \(coordinates) \n locality: \(locality) \n sublocality: \(subLocality) \n administrative area: \(administrativeArea) \n country: \(country) \n fullAddress \(fullAddress)"
    }
}

private let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
private let imageFileController = Globals.constants.appDelegate.imageFileController


func convertFirebaseObjectToSpotComponents(spotObject:FDataSnapshot) -> SpotComponents {
    
    let json = JSON(spotObject.value)
    let spotAddressComponents = SpotAddressComponents(
        coordinates: getCoordinatesFromlatlng(json["location"]["coordinates"]["lat"].double, lng: json["location"]["coordinates"]["lng"].double),
        locality: json["location"]["locality"].string,
        subLocality: json["location"]["subLocality"].string,
        administrativeArea: json["location"]["administrativeArea"].string,
        country: json["location"]["country"].string,
        fullAddress: json["location"]["address"].string
    )
    let spotComponents = SpotComponents(
        key: spotObject.key,
        user: nil,
        caption: json["caption"].string,
        hashTags: json["hashTags"].arrayValue.map { $0.string!},
        images: json["localImagePaths"].arrayValue.map { ImageComponents(image: nil, path: $0.string)},
        addressComponents: spotAddressComponents,
        date: convertTimeStampToNSDate(json["date"].double),
        isSynced: nil
    )
    
//    imageFileController?.appendToImageDownloadQueue(json["localImagePaths"].arrayValue.map { $0.string!})
    
    return spotComponents
}

func saveNewSpot(components: SpotComponents) {
//    print(components)
    
    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    let spotsRef = ref.childByAppendingPath("spots")
    
    var newSpot = [String:AnyObject]()
    var newSpotLocation = [String:AnyObject]()
    
    newSpot["caption"] = components.caption
    newSpot["hashTags"] = components.hashTags
    
    getImagePathsAndSave(components.images) { (imagePaths) -> () in
        newSpot["localImagePaths"] = imagePaths
    }
    newSpot["date"] = components.date?.timeIntervalSince1970
    if let coordinates = components.addressComponents.coordinates {
        newSpotLocation["coordinates"] = ["lat" : coordinates.latitude, "lng" : coordinates.longitude]
    }
    if let address = components.addressComponents.fullAddress {
        newSpotLocation["address"] = address
    }
    if let locality = components.addressComponents.locality {
        newSpotLocation["locality"] = locality
    }
    if let subLocality = components.addressComponents.subLocality {
        newSpotLocation["subLocality"] = subLocality
    }
    if let administrativeArea = components.addressComponents.administrativeArea {
        newSpotLocation["administrativeArea"] = administrativeArea
    }
    if let country = components.addressComponents.country {
        newSpotLocation["country"] = country
    }
    newSpot["location"] = newSpotLocation
    let newSpotRef = spotsRef.childByAutoId()
    print("KEY: \(newSpotRef.key)")

    newSpotRef.setValue(newSpot)
}

func getImagePathsAndSave(images:[ImageComponents], completion:(imagePaths:[String]) ->() ) {
    var imagePaths:[String] = []
    for var image in images {
        if image.path == nil {
            image.path = "\(randomStringWithLength(9)).jpg"
            if let jpgImageData = UIImageJPEGRepresentation(image.image!, 0.4) {
                imageFileController?.saveImageToApp(jpgImageData, imagePath: image.path!, completion: { (isSuccess) -> () in
                    imageFileController?.appendToImageUploadQueue(image.path!)
                })
            }
        }
        imagePaths.append(image.path!)
    }
    completion(imagePaths: imagePaths)
}

func updateSpot(components: SpotComponents) {
    
    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    let spotsRef = ref.childByAppendingPath("spots")
    let spotRef = spotsRef.childByAppendingPath(components.key)
    
    var paths:[String] = []
    getImagePathsAndSave(components.images) { (imagePaths) -> () in
        paths = imagePaths
    }

    spotRef.updateChildValues([
        "caption":components.caption!,
        "hashTags":components.hashTags!,
        "localImagePaths":paths        
    ])

//    newSpot["date"] = components.date?.timeIntervalSince1970
//    if let coordinates = components.addressComponents.coordinates {
//        newSpotLocation["coordinates"] = ["lat" : coordinates.latitude, "lng" : coordinates.longitude]
//    }
//    if let address = components.addressComponents.fullAddress {
//        newSpotLocation["address"] = address
//    }
//    if let locality = components.addressComponents.locality {
//        newSpotLocation["locality"] = locality
//    }
//    if let subLocality = components.addressComponents.subLocality {
//        newSpotLocation["subLocality"] = subLocality
//    }
//    if let administrativeArea = components.addressComponents.administrativeArea {
//        newSpotLocation["administrativeArea"] = administrativeArea
//    }
//    if let country = components.addressComponents.country {
//        newSpotLocation["country"] = country
//    }
//    newSpot["location"] = newSpotLocation
//    let newSpotRef = spotsRef.childByAutoId()
//    print("KEY: \(newSpotRef.key)")
    
    
}

func deleteSpot(components: SpotComponents) {
    
    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    let spotsRef = ref.childByAppendingPath("spots")
    let spotRef = spotsRef.childByAppendingPath(components.key)
    spotRef.removeValueWithCompletionBlock { (error, object) -> Void in
        if error == nil {
            print(imageFileController?.deleteImagesFromApp(components.images.map{$0.path!}))
        } else {
            print(error)
        }
    }
    
    //    let query = PFQuery(className:"Spot")
    //    query.fromLocalDatastore()
    //    query.whereKey("date", equalTo: spotComponents.date!)
    //    query.getFirstObjectInBackgroundWithBlock { (returnedSpotObject, error) -> Void in
    //        if let spotObject = returnedSpotObject  {
    //            spotObject.unpinInBackgroundWithBlock({ (success, error) -> Void in
    //                if success {
    //                    print(deleteImagesLocallyFromApp(spotObject["localImagePaths"] as? [String]))
    //                    spotObject.deleteEventually()
    //                }
    //            })
    //        }
    //    }
}

private func convertTimeStampToNSDate(timeStamp:Double?) -> NSDate? {
    if let timeStamp = timeStamp {
        return NSDate(timeIntervalSince1970: timeStamp)
    } else {
        return nil
    }
}

private func getCoordinatesFromlatlng(lat:Double?, lng:Double?) ->CLLocationCoordinate2D? {
    print("LAT: \(lat), LNG: \(lng)")
    if let lat = lat, lng = lng {
        return CLLocationCoordinate2DMake(lat,lng)
    } else {
        return nil
    }
}


func retrieveImageLocally(imagePath:String) -> UIImage? {
    let urlPath = NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(imagePath)
    if let imageData = NSData(contentsOfURL: urlPath) {
       return UIImage(data: imageData)
    } else {
        return nil
    }
}

func randomStringWithLength(len:Int) -> String {
    let letters:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    var randomString = ""
    for (var i=0; i < len; i++){
        let length:UInt32 = UInt32(letters.characters.count)
        let rand = arc4random_uniform(length)
        randomString.append(letters[letters.startIndex.advancedBy(Int(rand))])
    }
    return randomString
}