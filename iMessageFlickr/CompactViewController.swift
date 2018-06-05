//
//  CompactViewController.swift
//  iMessageFlickr
//
//  Created by Eldar Goloviznin on 15/05/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

protocol CompactDelegate: class {
    func startSearch()
}

class CompactViewController: UIViewController {
    
    weak var delegate: CompactDelegate?

    @IBAction func search(_ sender: Any) {
        delegate?.startSearch()
    }
    
}
