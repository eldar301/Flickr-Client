//
//  PhotoDetailsViewController.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 22.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var realnameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var descriptionTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    let dateFormatter = DateFormatter()
    
    var viewModel: PhotoDetailsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImageViews()
        configureDateFormatter()
        trySetupWithCachedData()

        viewModel.loadInfo { [weak self] in
            DispatchQueue.main.async {
                self?.setupWithUpdatedData()
            }
        }
    }
    
    func configureImageViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.clipsToBounds = true
    }
    
    func configureDateFormatter() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    func congifure(withPhoto photo: Photo) {
        viewModel = PhotoDetailsViewModel(withPhoto: photo)
    }
    
    func trySetupWithCachedData() {
        if let cachedImage = viewModel.photo.image {
            update(withImage: UIImage(data: cachedImage))
        }
    }
    
    func setupWithUpdatedData() {
        let photo = viewModel.photo
        titleLabel.text = photo.title
        
        let description = photo.description ?? ""
        if description.isEmpty {
            descriptionTextHeightConstraint.constant = 0
        } else {
            if let descriptionAsData = description.data(using: String.Encoding.utf8), let attributedDescription = try? NSAttributedString(data: descriptionAsData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                descriptionTextView.attributedText = attributedDescription
            } else {
                descriptionTextView.text = description
            }
            descriptionTextHeightConstraint.constant = descriptionTextView.contentSize.height
        }
        
        dateLabel.text = dateFormatter.string(from: photo.date ?? Date())
        usernameLabel.text = photo.owner?.username
        realnameLabel.text = photo.owner?.realname
        locationLabel.text = photo.owner?.location
        
        if imageView.image == nil {
            let imageTask = URLSession.shared.cachedImage(url: photo.url) { image in
                DispatchQueue.main.async { [weak self] in
                    self?.update(withImage: image)
                }
            }
            imageTask?.resume()
        }
        
        let avatarTask = URLSession.shared.cachedImage(url: photo.owner!.avatarUrl) { image in
            DispatchQueue.main.async { [weak self] in
                self?.avatarImageView.image = image
            }
        }
        avatarTask?.resume()
    }
    
    func update(withImage image: UIImage?) {
        imageView.image = image
        if let image = image?.cgImage {
            let imageViewWidth = imageView.bounds.width
            let rate = CGFloat(image.height) / CGFloat(image.width)
            imageHeightConstraint.constant = rate * imageViewWidth
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let user = viewModel.photo.owner {
            let vc = segue.destination as! UserDetailsViewController
            vc.viewModel = UserDetailsViewModel(withUser: user)
        }
    }
    
    @IBAction func onProfileIconClick(_ sender: Any) {
        self.performSegue(withIdentifier: "showUserProfile", sender: nil)
    }

}
