//
//  FlickrAPI.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import SwiftyJSON

enum FlickAPISearchSource {
    case text(String)
    case user(Owner)
}

protocol FlickrSearchAPI {
    func searchPhotos(fromSource: FlickAPISearchSource, page: Int, perPage: Int, completition: @escaping ([Photo], (currentPage: Int, totalPages: Int)) -> ())
    func cancel()
}

protocol FlickrPhotoAPI {
    func infoAbout(photo: Photo, completition: @escaping (Photo?) -> ())
}

protocol FlickrUserAPI {
    func infoAbout(user: Owner, completition: @escaping (Owner) -> ())
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
    
    func searchPhotos(fromSource source: FlickAPISearchSource, page: Int, perPage: Int, completition: @escaping ([Photo], (currentPage: Int, totalPages: Int)) -> ()) {
        var queries =
            ["api_key": apiKey,
             "per_page": String(perPage),
             "page": String(page)]
        
        switch source {
        case .text(let text):
            queries.updateValue(textSearchMethodName, forKey: "method")
            queries.updateValue(text, forKey: "text")
            
        case .user(let user):
            queries.updateValue(userSearchMethodName, forKey: "method")
            queries.updateValue(user.nsid, forKey: "user_id")
        }
        
        let url = buildURL(withQueries: queries)
        
        currentTask = URLSession.shared.data(request: URLRequest(url: url)) { data in
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
    
    func infoAbout(photo: Photo, completition: @escaping (Photo?) -> ()) {
        let queries =
            ["method": methodName,
             "api_key": apiKey,
             "photo_id": photo.id]
        
        let url = buildURL(withQueries: queries)
        
        URLSession.shared.data(request: URLRequest(url: url)) { data in
            guard let data = data else {
                return
            }
            
            guard let json = JSON(data).dictionary?["photo"]!.dictionary else {
                completition(nil)
                return
            }
            
            var owner: Owner?
            if let jsonOwner = json["owner"]?.dictionary,
                let nsid = jsonOwner["nsid"]?.string,
                let username = jsonOwner["username"]?.string,
                let realname = jsonOwner["realname"]?.string,
                let location = jsonOwner["location"]?.string,
                let iconserver = jsonOwner["iconserver"]?.string,
                let iconfarm = jsonOwner["iconfarm"]?.int,
                let avatarURL = URL(string: "http://farm\(iconfarm).staticflickr.com/\(iconserver)/buddyicons/\(nsid).jpg") {
                owner = Owner(nsid: nsid,
                              username: username,
                              realname: realname,
                              location: location,
                              avatarUrl: avatarURL)
            }
            
            var updatedPhoto = photo
            updatedPhoto.owner = owner
            
            if let title = json["title"]?.dictionary?["_content"]?.string,
                let description = json["description"]?.dictionary?["_content"]?.string,
                let date = json["dateuploaded"]?.numberValue {
                updatedPhoto.title = title
                updatedPhoto.description = description
                updatedPhoto.date = Date(timeIntervalSince1970: date.doubleValue)
            }
            
            completition(updatedPhoto)
        }
        .resume()
    }
    
}

class FlickrUserAPIDefault: FlickrAPI, FlickrUserAPI {
    
    let methodName = "flickr.people.getInfo"
    
    func infoAbout(user: Owner, completition: @escaping (Owner) -> ()) {
        let queries =
            ["method": methodName,
             "api_key": apiKey,
             "user_id]": user.nsid]
        
        let url = buildURL(withQueries: queries)
        
        URLSession.shared.data(request: URLRequest(url: url)) { data in
            guard let data = data else {
                return
            }
            
            var updatedUser = user
            
            if let json = JSON(data).dictionary,
                let username = json["username"]?.dictionary?["_content"]?.string,
                let realname = json["realname"]?.dictionary?["_content"]?.string,
                let description = json["description"]?.dictionary?["_content"]?.string,
                let location = json["location"]?.dictionary?["_content"]?.string {
                
                updatedUser.username = username
                updatedUser.realname = realname
                updatedUser.description = description
                updatedUser.location = location
            }
            
            completition(updatedUser)
        }
        .resume()
    }
    
}
