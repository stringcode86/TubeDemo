//
//  StopsViewController.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit
import MapKit

class StopsTableViewController: UITableViewController {

    var stopsService: StopsService = StopsService()
    
    private var stops = [
        Stop(
            naptanId: "one",
            name: "Old street",
            distance: 10,
            additionalProperties: []
        ),
        Stop(
            naptanId: "two",
            name: "Angel",
            distance: 20,
            additionalProperties: []
        )
    ]

    private var arrivals: [String: [Arrival]] = [:]
    
    
    private var selectedFacility: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let location = CLLocationCoordinate2D(
            latitude: 51.5155294,
            longitude: -0.1440504
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshStops(location: location)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return stops.count
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return arrivals(for: stops[section]).count + 1
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseId(for: indexPath.row),
            for: indexPath
        )

        if indexPath.row == 0 {
            configureStopCell(cell, stop: stops[indexPath.section])
        } else {
            configureArrivalCell(cell, arrival: arrival(for: indexPath))
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FacilityDetailViewController {
            destination.facility = selectedFacility
        }
    }
}

// MARK: - TableView utility methods

private extension StopsTableViewController {

    func configureArrivalCell(_ cell: UITableViewCell, arrival: Arrival) {
        cell.textLabel?.text = arrival.name
    }

    func configureStopCell(_ cell: UITableViewCell, stop: Stop) {
        let stopCell = cell as? StopTableViewCell
        stopCell?.titleLabel.text = stop.name
        stopCell?.setCollageItems(stop.facilities())
        stopCell?.delegate = self
    }

    func arrival(for indexPath: IndexPath) -> Arrival {
        return arrivals(for: stops[indexPath.section])[indexPath.row - 1]
    }
    
    func arrivals(for stop: Stop) -> [Arrival] {
        return arrivals[stop.naptanId] ?? []
    }
    
    func reuseId(for row: Int) -> String {
        return row == 0 ? Constant.stopReuseId : Constant.arrivalReuseId
    }
}

// MARK: - StopTableViewCellDelegate

extension StopsTableViewController: StopTableViewCellDelegate {

    func cell(cell: StopTableViewCell, didSelectCollageItemAt index: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        selectedFacility = stops[indexPath.section].facilities()[index]
        performSegue(withIdentifier: Constant.toFacilitySegueId, sender: cell)
    }
}

// MARK: - Refreshing stops

private extension StopsTableViewController {
    
    func refreshStops(location: CLLocationCoordinate2D) {
        stopsService.stopsNear(location: location) { stops, error in
            
            DispatchQueue.main.async {
                self.handleError(error)
                self.handleStops(stops)
            }
        }
    }
    
    func handleStops(_ stops: [Stop]) {
        var sectionsToDelete = [Int]()
        var sectionsToInsert = [Int]()

        while self.stops.count > stops.count {
            self.stops.removeLast()
            sectionsToDelete.append(self.stops.count)
        }
        
        let sectionsToReload = Array(0..<self.stops.count)

        if stops.count > self.stops.count {
            sectionsToInsert = Array(self.stops.count..<stops.count)
        }

        self.stops = stops

        tableView.beginUpdates()
        tableView.deleteSections(IndexSet(sectionsToDelete), with: .automatic)
        tableView.reloadSections(IndexSet(sectionsToReload), with: .automatic)
        tableView.insertSections(IndexSet(sectionsToInsert), with: .automatic)
        tableView.endUpdates()
    }
}

// MARK: - Generic error handling

private extension StopsTableViewController {
    
    func handleError(_ error: Error?) {
        guard let error = error else  {
            return
        }
        
        let alert = UIAlertController(
            title: Constant.genericErrorTitle,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        present(alert, animated: true)
    }
}


// MARK: - Constants

private extension StopsTableViewController {

    struct Constant {
        static let arrivalReuseId = "ArrivalCellReuseId"
        static let stopReuseId = "StopCellReuseId"
        static let toFacilitySegueId = "toFacilityDetail"
        static let genericErrorTitle = "Error"
    }
}
