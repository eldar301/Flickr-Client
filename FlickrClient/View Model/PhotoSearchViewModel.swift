//
//  PhotoSearchViewModel.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

class PhotoSearchViewModel {
    
    fileprivate let searchApi: FlickrSearchAPI = FlickrSearchAPIDefault()
    
    fileprivate let perPage = 50
    fileprivate var currentPage: Int!
    fileprivate var lastLoadedPage: Int!
    fileprivate var totalPages: Int!
    
    var photos: [Photo] = []
    
    func search(text: String, completition: @escaping () -> ()) {
        searchApi.cancel()
        photos = []
        doSearch(text: text, page: 1, completition: completition)
    }
    
    func loadNext(text: String, completition: @escaping () -> ()) {
        guard currentPage < totalPages, currentPage == lastLoadedPage else {
            return
        }
        searchApi.cancel()
        currentPage = currentPage + 1
        doSearch(text: text, page: currentPage, completition: completition)
    }
    
    fileprivate func doSearch(text: String, page: Int, completition: @escaping () -> ()) {
        searchApi.searchPhotos(fromSource: .text(text), page: page, perPage: perPage) { [weak self] (photos, timeline) in
            guard let strongSelf = self else { return }
            strongSelf.currentPage = timeline.currentPage
            strongSelf.lastLoadedPage = timeline.currentPage
            strongSelf.totalPages = timeline.totalPages
            strongSelf.photos.append(contentsOf: photos)
            completition()
        }
    }
}
