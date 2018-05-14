//
//  PhotoSearchViewController.swift
//  FlickrClient
//
//  Created by Eldar Goloviznin on 21.04.18.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

class PhotoSearchViewController: UIViewController {
    
    let reusableIdentifier = "PhotoCell"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = PhotoSearchViewModel()
    
    private let spaceBetweenCells: CGFloat = 2
    
    private var needToScrollTop: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.callback = self
        
        configureCollectionView()
        configureSearchBar()
        configurePreviewDetails()
    }
    
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
    }
    
    func configurePreviewDetails() {
        self.registerForPreviewing(with: self, sourceView: collectionView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails", let selectedPhoto = sender as? Photo  {
            let detailsVC = segue.destination as! PhotoDetailsViewController
            detailsVC.photo = selectedPhoto
        }
    }

}

extension PhotoSearchViewController: PhotoSearchCallback {
    
    func searchCompleted() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.needToScrollTop {
                self.collectionView.contentOffset = .zero
            }
        }
    }
    
    func searchFailed() {
        
    }
    
}

extension PhotoSearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifier, for: indexPath) as! PhotoCell
        
        let photo = viewModel.photos[indexPath.row]
        cell.configureView(withPhoto: photo)
        
        return cell
    }
    
}

extension PhotoSearchViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !searchBar.text!.isEmpty else { return }
        if scrollView.contentSize.height - scrollView.contentOffset.y < scrollView.bounds.height * 4 {
            needToScrollTop = false
            viewModel.loadNext(text: searchBar.text!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width  - spaceBetweenCells) / 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = viewModel.photos[indexPath.row]
        self.performSegue(withIdentifier: "showDetails", sender: photo)
    }
    
}

extension PhotoSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard !searchBar.text!.isEmpty else {
            return
        }
        
        needToScrollTop = true
        searchBar.resignFirstResponder()
        viewModel.search(text: searchBar.text!)
    }
    
}

extension PhotoSearchViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: location), let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        
        previewingContext.sourceRect = cell.frame
        
        let photo = viewModel.photos[indexPath.row]
        let detailsVC = storyboard!.instantiateViewController(withIdentifier: "showDetails") as! PhotoDetailsViewController
        detailsVC.photo = photo
        
        return detailsVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}
