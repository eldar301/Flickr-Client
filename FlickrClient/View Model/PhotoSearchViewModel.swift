//
//  PhotoSearchViewModel.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

protocol PhotoSearchCallback: class {
    func searchCompleted()
    func searchFailed()
}

class PhotoSearchViewModel {
    
    weak var callback: PhotoSearchCallback?
    
    fileprivate let searchApi: FlickrSearchAPI = FlickrSearchAPIDefault()
    
    fileprivate let perPage = 50
    fileprivate var currentPage: Int!
    fileprivate var lastLoadedPage: Int!
    fileprivate var total: Int!
    
    var photos: [Photo] = []
    
    private var inProgress: Bool = false
    
    func search(text: String) {
        searchApi.cancel()
        photos = []
        doSearch(text: text, page: 1)
    }
    
    func loadNext(text: String) {
        guard photos.count < total, !inProgress else {
            return
        }
        
        inProgress = true
        searchApi.cancel()
        doSearch(text: text, page: currentPage + 1)
    }
    
    fileprivate func doSearch(text: String, page: Int) {
        searchApi.searchPhotos(withText: text, page: page, perPage: perPage) { [weak self] (newPhotos, timeline) in
            self?.inProgress = false
            self?.currentPage = timeline.currentPage
            self?.lastLoadedPage = timeline.currentPage
            self?.total = timeline.total
            self?.photos.append(contentsOf: newPhotos)
            self?.callback?.searchCompleted()
        }
    }
}
