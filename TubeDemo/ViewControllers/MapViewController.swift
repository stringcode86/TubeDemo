//
//  ViewController.swift
//  TubeDemo
//
//  Created by stringCode on 09/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate: class {
    func mapViewController(mapViewController: MapViewController,
                           didChange location: CLLocationCoordinate2D)
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    weak var delegate: MapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.setVisibleMapRect(
            MKMapRect(
                origin: MKMapPoint(Constant.defaultLocation),
                size: Constant.defaultSize
            ),
            animated: true
        )
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapViewController(
            mapViewController: self,
            didChange: mapView.region.center
        )
    }
}

// MARK: - Constants

private extension MapViewController {
    
    struct Constant {
        static let defaultSize = MKMapSize(width: 1000, height: 1000)
        static let defaultLocation = CLLocationCoordinate2D(
            latitude: 51.5155294,
            longitude: -0.1440504
        )
    }
}
