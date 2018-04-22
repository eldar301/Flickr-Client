//
//  Photo.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

struct Photo {
    var id: String
    var url: URL
    var image: Data?
    var title: String?
    var description: String?
    var date: Date?
    var owner: Owner?
    
    init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
}

