//
//  HomeViewController.swift
//  TubeDemo
//
//  Created by stringCode on 11/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

/// `HomeViewController` extremely rudimentary simple container controller. Ideally I would have
/// love to implement custom containment controller [Example of custom containment controller I
/// did in the past](https://github.com/stringcode86/DrawerController).
/// This controller simply embeds `MapViewController` and `StopsViewController`
/// via embedding segues and hock up delelegate.
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
