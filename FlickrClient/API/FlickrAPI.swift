//
//  FlickrAPI.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol FlickrSearchAPI {
    func searchPhotos(withText: String, page: Int, perPage: Int, completition: @escaping ([Photo], (currentPage: Int, total: Int)) -> ())
    func cancel()
}

class FlickrAPI {
    
    let apiKey = "20445f2ee31ffa6fe4bce7278b2bad5c"
    let baseURL = "https://api.flickr.com/services/rest/"
    let defaultQueries = ["format": "json", "nojsoncallback": "1"].map { URLQueryItem(name: $0, value: $1) }
    
    func buildURL(withQueries queries: [String: String]) -> URL {
        var queryItems = queries.map { URLQueryItem(name: $0, value: $1) }
        queryItems.append(contentsOf: defaultQueries)
        
        var components = URLComponents(url: URL(string: baseURL)!, resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        
        return components.url!
    }
    
}

class FlickrSearchAPIDefault: FlickrAPI, FlickrSearchAPI {
    
    var currentTask: URLSessionDataTask?
    let textSearchMethodName = "flickr.photos.search"
    let userSearchMethodName = "flickr.people.getPhotosOf"
    
    func searchPhotos(withText text: String, page: Int, perPage: Int, completition: @escaping ([Photo], (currentPage: Int, total: Int)) -> ()) {
        let queries =
            ["api_key": apiKey,
             "per_page": String(perPage),
             "page": String(page),
             "method": textSearchMethodName,
             "text": text]

        let url = self.buildURL(withQueries: queries)
        
        currentTask = URLSession.shared.data(request: URLRequest(url: url)) { data in
            guard let data = data else {
                return
            }
            
            let json = JSON(data).dictionary!["photos"]!.dictionary!
            
            let page = json["page"]!.intValue
            let total = json["total"]!.intValue
            
            let jsonPhotos = json["photo"]!.array!
            let photos = jsonPhotos.map { jsonPhoto -> Photo in
                let dictionary = jsonPhoto.dictionary!
                let id = dictionary["id"]!.string!
                let farm = dictionary["farm"]!.int!
                let server = dictionary["server"]!.string!
                let secret = dictionary["secret"]!.string!
                let thumbnailURL = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg")!
                let fullsizeURL = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")!
                return Photo(id: id, thumbnailURL: thumbnailURL, fullsizeURL: fullsizeURL)
            }
            
            completition(photos, (currentPage: page, total: total))
        }
        
        currentTask?.resume()
    }
    
    func cancel() {
        currentTask?.cancel()
    }
    
}
