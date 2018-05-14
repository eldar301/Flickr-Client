//
//  PhotoDetailsViewController.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 14/05/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var photo: Photo!
    
    let maximumZoomScale: CGFloat = 4
    let minimumZoomScale: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImageView()
        setupImage()
        configureScrollView()
    }
    
    func configureImageView() {
        imageView.contentMode = .scaleAspectFit
        
        imageView.isUserInteractionEnabled = true
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewDoubleTap(gestureRecognizer:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    @objc func imageViewDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale != minimumZoomScale {
            scrollView.setZoomScale(minimumZoomScale, animated: true)
        } else {
            let tapPoint = gestureRecognizer.location(in: scrollView)
            let rectToZoom = CGRect(origin: tapPoint, size: .zero)
            scrollView.zoom(to: rectToZoom, animated: true)
        }
    }
    
    func setupImage() {
        let fullsizeURL = photo.fullsizeURL
        if let cachedFullsizeImage = URLSession.shared.cachedImage(url: fullsizeURL) {
            self.imageView.image = cachedFullsizeImage
        } else if let cachedThumbnailImage = URLSession.shared.cachedImage(url: photo.thumbnailURL) {
            self.imageView.image = cachedThumbnailImage
            let fullsizeImageTask = URLSession.shared.cachedImage(url: fullsizeURL) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
            fullsizeImageTask?.resume()
        }
    }
    
    func configureScrollView() {
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.delegate = self
    }
    
    @IBAction func exportImage(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [self.imageView.image], applicationActivities: nil)
        self.present(activityController, animated: true)
    }
    
}

extension PhotoDetailsViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
