//
//  ExpandedViewController.swift
//  iMessageFlickr
//
//  Created by Eldar Goloviznin on 15/05/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

protocol ExpandedDelegate: class {
    func chosen(photo: Photo)
}

class ExpandedViewController: PhotoSearchViewController {
    
    weak var delegate: ExpandedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.unconfigurePreviewDetails()
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = viewModel.photos[indexPath.row]
        delegate?.chosen(photo: photo)
    }

}
