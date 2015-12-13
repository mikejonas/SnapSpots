//
//  ReturnSpotsUtil.swift
//  SnapSpots
//
//  Created by Mike Jonas on 11/28/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

protocol ReturnSpotsUtilDelegate {
    func updateSpots()
}

class ReturnSpotsUtil {
    var ref = Firebase(url:"https://snapspot.firebaseio.com")
    var delegate: ReturnSpotsUtilDelegate?
    var fUserId:String?
    var groupsRefPath:String?
    var groups:[String] = []
    var spots:[SpotComponents] = []
    
    var hashtagsArr:[ (SpotGroupComponents, [(String,Int)]) ] = []
    var selectedHashtags:[(groupId: String, hashtag: String)] = []

    var observedTags:[String] = []
    var observedGroups:[String] = []

    
    init() {
        getFUserId()
        observeGroups()
        observeHashtags()
    }
    
    func clearFirebaseObservers() {
        for refPath in observedTags {
            ref.childByAppendingPath(refPath).removeAllObservers()
            spots = []
        }
    }
    
    func observeGroups() {
        if let userId = fUserId {
            groupsRefPath = "users_groups/\(userId)";
            ref.childByAppendingPath(groupsRefPath).observeEventType(.Value, withBlock: { snapshot in
                let json = JSON(snapshot.value)
                for group in json {
                    self.groups.append(group.0)
                }
                self.observeSpotsPaths()
                self.observeHashtags()
            })
        }
    }
    
    func observeHashtags() {
        for group in groups {
            var arr:[(String,Int)] = [];
            self.ref.childByAppendingPath("groups_hashtags/\(group)").observeEventType(.Value, withBlock: { snapshot in
                var groupComponents = SpotGroupComponents()
                groupComponents.groupId = snapshot.key
                for tag in JSON(snapshot.value) {
                    arr.append((tag.0, tag.1.count))
                }
                self.ref.childByAppendingPath("groups/\(snapshot.key)").observeSingleEventOfType(.Value, withBlock: { snapshot in
                    groupComponents.groupName = JSON(snapshot.value)["name"].string
                    self.hashtagsArr.append( (groupComponents, arr ) )
                })
            })
        }
    }
    
    
    func observeSpotsPaths() {
        if observedGroups.count == 0 && observedTags.count == 0 {
            for group in groups {
                observeSpotsAtPath("groups_spots/\(group)")
            }
        }
        if observedGroups.count > 0 {
            for group in observedGroups {
                observeSpotsAtPath("groups_spots/\(group)")
            }
        }
        if observedTags.count > 0 {
            for tag in observedTags {
                observeSpotsAtPath("groups_hashtags/\(tag)")
            }
        }
    }
    
    
    
    func observeSpotsAtPath(path:String) {
        self.ref.childByAppendingPath(path).observeEventType(.ChildAdded, withBlock: { snapshot in
            let spotPath = "spots/\(snapshot.key)"
            self.addToSpots(spotPath)
            print("ADDED???????")
        })
        self.ref.childByAppendingPath(path).observeEventType(.ChildRemoved, withBlock: { snapshot in
            if let i = self.spots.indexOf({$0.key == snapshot.key}) {
                self.spots.removeAtIndex(i)
                self.delegate?.updateSpots()
                print("REMOVED!")
            }
        })
    }
    
    func addToSpots(spotPath:String) {
        ref.childByAppendingPath(spotPath).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                self.spots.insert(convertFirebaseObjectToSpotComponents(snapshot), atIndex: 0)
                self.delegate?.updateSpots()
            }

        })
    }
    
    
    func getFUserId(){
        if let authData = ref.authData {
            if fUserId != authData.uid {
                groups = []
                fUserId = authData.uid
            }
        } else {
            fUserId = nil
            groups = []
        }
    }
    
    func getFHashtags() {
        
    }
    
    func loginFUser() {
        
    }
    
    func logoutFUser() {
        groupsRefPath = nil
        groups = []
        observedTags = []
    }
    
}