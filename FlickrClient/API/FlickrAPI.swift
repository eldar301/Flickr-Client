//
//  FlickrAPI.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol FlickSearchAPI {
    func searchPhotos(withText text: String, page: Int, perPage: Int, completition: @escaping ([Photo], (currentPage: Int, totalPages: Int)) -> ())
    func cancel()
}

protocol FlickPhotoAPI {
    func infoAboutPhoto(withID id: Int, completition: @escaping () -> ())
}

class FlickrSearchAPIDefault: FlickSearchAPI {
    
    var currentTask: URLSessionDataTask?
    
    fileprivate let apiKey = "20445f2ee31ffa6fe4bce7278b2bad5c"
    fileprivate let baseURL = "https://api.flickr.com/services/rest/"
    fileprivate let methodName = "flickr.photos.search"
    
    fileprivate let defaultQueries = ["format": "json", "nojsoncallback": "1"].map { URLQueryItem(name: $0, value: $1) }
    
    func searchPhotos(withText text: String, page: Int, perPage: Int, completition: @escaping ([Photo], (currentPage: Int, totalPages: Int)) -> ()) {
        var queryItems =
            ["method": methodName,
             "api_key": apiKey,
             "text": text,
             "per_page": String(perPage),
             "page": String(page)]
                .map { URLQueryItem(name: $0, value: $1) }
        queryItems.append(contentsOf: defaultQueries)
        
        var components = URLComponents(url: URL(string: baseURL)!, resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        
        currentTask = URLSession.shared.data(request: URLRequest(url: components.url!)) { data in
            guard let data = data else {
                return
            }
            
            let json = JSON(data).dictionary!["photos"]!.dictionary!
            
            let page = json["page"]!.intValue
            let totalPages = json["total"]!.intValue
            
            let jsonPhotos = json["photo"]!.array!
            let photos = jsonPhotos.map { jsonPhoto -> Photo in
                let dictionary = jsonPhoto.dictionary!
                let id = dictionary["id"]!.string!
                let farm = dictionary["farm"]!.int!
                let server = dictionary["server"]!.string!
                let secret = dictionary["secret"]!.string!
                return Photo(id: id,
                             farm: farm,
                             server: server,
                             secret: secret,
                             url: URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")!)
            }
            
            completition(photos, (currentPage: page, totalPages: totalPages))
        }
        
        currentTask?.resume()
    }
    
    func cancel() {
        currentTask?.cancel()
    }
    
}

class FlickPhotoAPIDefault: FlickPhotoAPI {
    
    func infoAboutPhoto(withID id: Int, completition: @escaping () -> ()) {
        
    }
    
}
