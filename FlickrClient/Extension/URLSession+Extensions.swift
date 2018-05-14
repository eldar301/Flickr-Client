//
//  URLSession+Extensions.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import UIKit

let cache = NSCache<NSURL, UIImage>()

extension URLSession {
    
    func setCache(limit: Int) {
        cache.countLimit = limit
    }
    
    func data(request: URLRequest, completition: @escaping (Data?) -> ()) -> URLSessionDataTask {
        return self.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, let response = response else {
                completition(nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, 200 ..< 300 ~= httpResponse.statusCode else {
                completition(nil)
                return
            }
            
            completition(data)
        })
    }
    
    func cachedImage(url: URL, completition: @escaping (UIImage?) -> ()) -> URLSessionDataTask? {
        if let cached = cachedImage(url: url) {
            completition(cached)
            return nil
        }
        return data(request: URLRequest(url: url), completition: { data in
            guard let data = data else {
                completition(nil)
                return
            }
            
            let image = UIImage(data: data)
            if image != nil {
                cache.setObject(image!, forKey: url as NSURL)
            }
            
            completition(image)
        })
    }
    
    func cachedImage(url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
}
