//
//  StopsViewController.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

class StopsTableViewController: UITableViewController {

    private var stops = [
        Stop(name: "Old street",
             arrivals: [
                Arrival(name: "First"),
                Arrival(name: "Second"),
                Arrival(name: "Third")
            ]
        ),
        Stop(name: "Angel",
             arrivals: [
                Arrival(name: "1st"),
                Arrival(name: "2nd")
            ]
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return stops.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops[section].arrivals.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
}

// MARK: - TableView utility methods

private extension StopsTableViewController {

    func configureArrivalCell(_ cell: UITableViewCell, arrival: Arrival) {
        cell.textLabel?.text = arrival.name
    }

    func configureStopCell(_ cell: UITableViewCell, stop: Stop) {
        let stopCell = cell as? StopTableViewCell
        stopCell?.titleLabel.text = stop.name
    }

    func arrival(for indexPath: IndexPath) -> Arrival {
        return stops[indexPath.section].arrivals[indexPath.row - 1]
    }

    func reuseId(for row: Int) -> String {
        return row == 0 ? Constant.stopReuseId : Constant.arrivalReuseId
    }
}

// MARK: - Constants

private extension StopsTableViewController {

    struct Constant {
        static let arrivalReuseId = "ArrivalCellReuseId"
        static let stopReuseId = "StopCellReuseId"
    }
}
