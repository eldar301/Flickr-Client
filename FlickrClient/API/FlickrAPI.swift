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
    func searchPhotos(withText text: String, page: Int, perPage: Int, completition: @escaping ([Photo], (currentPage: Int, totalPages: Int)) -> ())
    func cancel()
}

protocol FlickrPhotoAPI {
    func infoAbout(photo: Photo, completition: @escaping (Photo) -> ())
}

class FlickrAPI {
    
    let apiKey = "20445f2ee31ffa6fe4bce7278b2bad5c"
    let baseURL = "https://api.flickr.com/services/rest/"
    let defaultQueries = ["format": "json", "nojsoncallback": "1"].map { URLQueryItem(name: $0, value: $1) }
    
}

class FlickrSearchAPIDefault: FlickrAPI, FlickrSearchAPI {
    
    var currentTask: URLSessionDataTask?
    let methodName = "flickr.photos.search"
    
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
                let url = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")!
                return Photo(id: id, url: url)
            }
            
            completition(photos, (currentPage: page, totalPages: totalPages))
        }
        
        currentTask?.resume()
    }
    
    func cancel() {
        currentTask?.cancel()
    }
    
}

class FlickrPhotoAPIDefault: FlickrAPI, FlickrPhotoAPI {
    
    let methodName = "flickr.photos.getInfo"
    
    func infoAbout(photo: Photo, completition: @escaping (Photo) -> ()) {
        var queryItems =
            ["method": methodName,
             "api_key": apiKey,
             "photo_id": photo.id]
            .map { URLQueryItem(name: $0, value: $1) }
        queryItems.append(contentsOf: defaultQueries)
        
        var components = URLComponents(url: URL(string: baseURL)!, resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        
        URLSession.shared.data(request: URLRequest(url: components.url!)) { data in
            guard let data = data else {
                return
            }
            
            let json = JSON(data).dictionary!["photo"]!.dictionary!
            
            let jsonOwner = json["owner"]!.dictionary!
            let nsid = jsonOwner["nsid"]!.string!
            let username = jsonOwner["username"]!.string!
            let realname = jsonOwner["realname"]!.string!
            let location = jsonOwner["location"]!.string!
            let iconserver = jsonOwner["iconserver"]!.string!
            let iconfarm = jsonOwner["iconfarm"]!.int!
            let avatarURL = URL(string: "http://farm\(iconfarm).staticflickr.com/\(iconserver)/buddyicons/\(nsid).jpg")!
            let owner = Owner(username: username,
                              realname: realname,
                              location: location,
                              avatarUrl: avatarURL)
            
            let title = json["title"]!.dictionary!["_content"]!.string!
            let description = json["description"]!.dictionary!["_content"]!.string!
            let date = json["dateuploaded"]!.numberValue
            
            var updatedPhoto = photo
            updatedPhoto.title = title
            updatedPhoto.description = description
            updatedPhoto.date = Date(timeIntervalSince1970: date.doubleValue)
            updatedPhoto.owner = owner
            
            completition(updatedPhoto)
        }
        .resume()
    }
    
}
