//
//  Globals.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 9/6/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation
import Firebase

struct Globals {
    struct variables {
        static var filterSpotsHashtag:[String] = []
        static var hashtags:[String] = []
    }
    
    struct constants {
        static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        static let defaults = NSUserDefaults.standardUserDefaults()
    }
}