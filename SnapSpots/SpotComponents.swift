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
    var localImagePaths: [String] = []
    var images: [UIImage] = []
    var addressComponents = SpotAddressComponents()
    var date:NSDate?
    var isSynced:Bool?
    var description: String {
        return "\n caption: \(caption) \n hashTags: \(hashTags) \n images: \(images) \(localImagePaths) \n addressComponents: \(addressComponents)"
    }
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
        localImagePaths: json["localImagePaths"].arrayValue.map { $0.string!},
        images: [],
        addressComponents: spotAddressComponents,
        date: convertTimeStampToNSDate(json["date"].double),
        isSynced: nil
    )
    
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
    newSpot["localImagePaths"] = components.localImagePaths
    
    imageFileController?.saveImagesLocally(components.images, imagePaths: newSpot["localImagePaths"] as! [String])
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
    newSpotRef.setValue(newSpot)
}

func updateSpot(newComponents: SpotComponents, oldComponents: SpotComponents) {
    
    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    let spotsRef = ref.childByAppendingPath("spots")
    let spotRef = spotsRef.childByAppendingPath(newComponents.key)
    print(spotRef)
    spotRef.updateChildValues([
        "caption":newComponents.caption!,
        "hashTags":newComponents.hashTags!,
        "localImagePaths":newComponents.localImagePaths
    ])
    
    
    //    let newComponentsImagePaths = components.localImagePaths
    //    let localComponentsImagePaths = spotRef["localImagePaths"] as! [String]
    //
    //    //DELETE IMAGES
    //    var imagesToDelete:[String] = []
    //    for imagePath in localComponentsImagePaths {
    //        if !newComponentsImagePaths.contains(imagePath) {
    //            imagesToDelete.append(imagePath)
    //        }
    //    }
    //    deleteImagesLocallyFromApp(imagesToDelete)
    //    //Save Images
    //    var imagesToSave:[UIImage] = []
    //    var imagePathsToSave:[String] = []
    //    for (i, newImagePath) in newComponentsImagePaths.enumerate() {
    //        if !localComponentsImagePaths.contains(newImagePath) {
    //            imagesToSave.append(components.images[i])
    //            imagePathsToSave.append(newImagePath)
    //        }
    //    }
    //    saveImagesLocally(imagesToSave, newImagePaths: imagePathsToSave)
    
}

func deleteSpot(components: SpotComponents) {
    
    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    let spotsRef = ref.childByAppendingPath("spots")
    let spotRef = spotsRef.childByAppendingPath(components.key)
    spotRef.removeValueWithCompletionBlock { (error, object) -> Void in
        if error == nil {
            print(imageFileController?.deleteImagesLocally(components.localImagePaths))
            
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


func retrieveImagesLocally(imageFileNames:[String]) -> [UIImage] {
    var images:[UIImage] = []

    for imageFileName in imageFileNames {
        let path = NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(imageFileName)
        if let imageData = NSData(contentsOfURL: path) {
            images.append(UIImage(data: imageData)!)
        }
    }
    return images
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