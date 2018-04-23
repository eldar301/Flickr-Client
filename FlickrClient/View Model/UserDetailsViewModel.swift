//
//  UserDetailsViewModel.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 23.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

class UserDetailsViewModel {
    
    fileprivate let api: FlickrUserAPIDefault = FlickrUserAPIDefault()
    
    var user: Owner
    
    init(withUser user: Owner) {
        self.user = user
    }
    
    func loadInfo(completition: @escaping () -> ()) {
        api.infoAbout(user: user) { [weak self] user in
            self?.user = user
            completition()
        }
    }
}
