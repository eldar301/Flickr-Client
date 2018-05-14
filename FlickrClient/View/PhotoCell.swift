//
//  PhotoCell.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var acitivtyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageTask: URLSessionDataTask?
    
    var photo: Photo!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.contentMode = .scaleAspectFill
        self.acitivtyIndicator.hidesWhenStopped = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageTask?.cancel()
        imageView.image = nil
        imageView.stopAnimating()
    }
    
    func configureView(withPhoto photo: Photo) {
        self.photo = photo
        let url = photo.thumbnailURL
        if let cached = URLSession.shared.cachedImage(url: url) {
            self.imageView.image = cached
        } else {
            self.acitivtyIndicator.startAnimating()
            imageTask = URLSession.shared.cachedImage(url: url, completition: { [weak self] image in
                DispatchQueue.main.async {
                    self?.acitivtyIndicator.stopAnimating()
                    self?.imageView.image = image
                }
            })
            imageTask?.resume()
        }
    }
    
}
