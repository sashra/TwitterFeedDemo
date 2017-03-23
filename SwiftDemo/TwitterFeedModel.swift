//
//  TwitterFeedModel.swift
//  SwiftDemo
//
//  Created by Shivani Ashra on 22/03/17.
//  Copyright (c) 2015 Shivani Ashra. All rights reserved.
//

import Foundation

struct TwitterFeedModel {
    var name: String?
    var profileURL: String?
    
    init (name: String, url: String) {
        self.name = name
        self.profileURL = url
    }
}