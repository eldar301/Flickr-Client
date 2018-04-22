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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureSearchBar()
    }
    
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
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
            viewModel.loadNext(text: searchBar.text!, completition: { [weak self] in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        let photo = cell.photo
        let viewController = storyboard?.instantiateViewController(withIdentifier: "photoDetails") as! PhotoDetailsViewController
        viewController.congifure(withPhoto: photo!)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension PhotoSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard !searchBar.text!.isEmpty else { return }
        viewModel.search(text: searchBar.text!) { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
}
