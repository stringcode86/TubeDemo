//
//  HomeViewController.swift
//  TubeDemo
//
//  Created by stringCode on 11/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    weak var mapViewController: MapViewController?
    weak var stopsViewController: StopsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapViewController?.delegate = stopsViewController
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constant.mapEmbedSegue:
            mapViewController = segue.destination as? MapViewController
        case Constant.stopsEmbedSegue:
            stopsViewController = segue.destination as? StopsTableViewController
        default:
            ()
        }
    }
}

// MARK: - Constants

private extension HomeViewController {
    
    struct Constant {
        static let mapEmbedSegue = "mapEmbedSegue"
        static let stopsEmbedSegue = "stopsEmbedSegue"
    }
}
