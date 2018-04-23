//
//  Ownter.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 22.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

struct Owner {
    var nsid: String
    var username: String
    var realname: String
    var description: String?
    var location: String
    var avatarUrl: URL
    
    init(nsid: String, username: String, realname: String, location: String, avatarUrl: URL) {
        self.nsid = nsid
        self.username = username
        self.realname = realname
        self.location = location
        self.avatarUrl = avatarUrl
    }
}
