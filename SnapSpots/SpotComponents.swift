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
        return "\n key: \(key) \n caption: \(caption) \n hashTags: \(hashTags) \n images: \(images) \n addressComponents: \(addressComponents) \n"
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

struct SpotGroupComponents {
    var groupName:String!
    var groupID:String!
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

func saveNewSpot(components: SpotComponents, group: SpotGroupComponents) {

    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    let spot = convertSpotComponentsIntoDictionary(components)
    
    let newSpotRef = ref.childByAppendingPath("spots").childByAutoId()
    let newSpotKey = newSpotRef.key
    
    let updatedData = [
        "spots/\(newSpotKey)" : spot,
        "groups_spots/\(group.groupID)/\(newSpotKey)" : true
    ]
    
    ref.updateChildValues(updatedData as [NSObject : AnyObject]) { (error, ref) -> Void in
        
    }
    
}



func updateSpot(components: SpotComponents) {
    
    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    let spotRef = ref.childByAppendingPath("spots").childByAppendingPath(components.key)
    
    let spot = convertSpotComponentsIntoDictionary(components)

    
    spotRef.updateChildValues(spot)
    
}

func convertSpotComponentsIntoDictionary(components: SpotComponents) -> [String : AnyObject] {
    var spot = [String:AnyObject]()
    var spotLocation = [String:AnyObject]()
    
    spot["caption"] = components.caption
    spot["hashTags"] = components.hashTags
    
    getImagePathsAndSave(components.images) { (imagePaths) -> () in
        spot["localImagePaths"] = imagePaths
    }
    spot["date"] = components.date?.timeIntervalSince1970
    if let coordinates = components.addressComponents.coordinates {
        spotLocation["coordinates"] = ["lat" : coordinates.latitude, "lng" : coordinates.longitude]
    }
    if let address = components.addressComponents.fullAddress {
        spotLocation["address"] = address
    }
    if let locality = components.addressComponents.locality {
        spotLocation["locality"] = locality
    }
    if let subLocality = components.addressComponents.subLocality {
        spotLocation["subLocality"] = subLocality
    }
    if let administrativeArea = components.addressComponents.administrativeArea {
        spotLocation["administrativeArea"] = administrativeArea
    }
    if let country = components.addressComponents.country {
        spotLocation["country"] = country
    }
    spot["location"] = spotLocation
    
    return spot
}


func deleteSpot(components: SpotComponents) {
    
    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    let spotsRef = ref.childByAppendingPath("spots")
    let spotRef = spotsRef.childByAppendingPath(components.key)
    spotRef.removeValueWithCompletionBlock { (error, object) -> Void in
        if error == nil {
            imageFileController?.deleteImages(components.images.map{$0.path!})
        } else {
            print(error)
        }
    }
}

// Maybe change this around to not use a completion
private func getImagePathsAndSave(images:[ImageComponents], completion:(imagePaths:[String]) ->() ) {
    var imagePaths:[String] = []
    for var image in images {
        if image.path == nil {
            image.path = "\(randomStringWithLength(9)).jpg"
            if let jpgImageData = UIImageJPEGRepresentation(image.image!, 0.4) {
                imageFileController?.saveImageToApp(jpgImageData, imagePath: image.path!, completion: { (isSuccess) -> () in
                    imageFileController?.appendToImageUploadQueue(image.path!)
                    imageFileController?.saveAllImagesFromAppToCloud()
                })
            }
        }
        imagePaths.append(image.path!)
    }

    completion(imagePaths: imagePaths)
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