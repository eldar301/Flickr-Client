//
//  UserDetailsViewController.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 23.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var realnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var viewModel: UserDetailsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.loadInfo {
            DispatchQueue.main.async { [weak self] in
                self?.setupWithUpdatedData()
            }
        }
    }
    
    func setupWithUpdatedData() {
        let user = viewModel.user
        
        realnameLabel.text = user.realname
        realnameLabel.sizeToFit()
        usernameLabel.text = user.username
        usernameLabel.sizeToFit()
        descriptionTextView.text = user.description
        locationLabel.text = user.location
        locationLabel.sizeToFit()
        
        let avatarTask = URLSession.shared.cachedImage(url: user.avatarUrl) { image in
            DispatchQueue.main.async { [weak self] in
                self?.avatarImageView.image = image
            }
        }
        avatarTask?.resume()
    }

}
