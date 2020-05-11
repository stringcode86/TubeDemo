//
//  FacilityDetailViewController.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

class FacilityDetailViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var facility: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = facility
        navigationBar.topItem?.title = title
    }
}

