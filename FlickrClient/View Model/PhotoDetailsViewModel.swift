//
//  PhotoViewModel.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

class PhotoDetailsViewModel {
    
    fileprivate let photoApi: FlickrPhotoAPIDefault = FlickrPhotoAPIDefault()

    var photo: Photo
    
    init(withPhoto photo: Photo) {
        self.photo = photo
    }
    
    func loadInfo(completition: @escaping () -> ()) {
        photoApi.infoAbout(photo: photo) { [weak self] updatedPhoto in
            if updatedPhoto != nil {
                self?.photo = updatedPhoto!
            }
            completition()
        }
    }
    
}
