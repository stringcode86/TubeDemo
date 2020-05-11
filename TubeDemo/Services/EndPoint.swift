//
//  EndPoint.swift
//  TubeDemo
//
//  Created by stringCode on 09/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation

enum EndPoint {
    case nearByStations(lat: Double, lon: Double, radius: Int)
    case arrivals(id: String)
}

// MARK: - NetworkEndPoint

extension EndPoint: NetworkEndPoint {

    var path: String {
        switch self {
        case .nearByStations:
            return "Stoppoint"
        case let .arrivals(id):
            return "Stoppoint/\(id)/Arrivals"
        }
    }

    var queryItems: Dictionary<String, String>? {
        switch self {
        case let .nearByStations(lat, lon, radius):
            return [
                "lon": "\(lon)",
                "lat": "\(lat)",
                "radius": "\(radius)",
                "stoptypes": Constant.stopTypes,
                "modes": Constant.modes,
                "app_id": Credentials.id.rawValue,
                "app_key": Credentials.key.rawValue

            ]
        case .arrivals:
            return [
                "modes": Constant.modes,
                "app_id": Credentials.id.rawValue,
                "app_key": Credentials.key.rawValue

            ]
        }
    }

    var url: URL {
        return Constant.baseURL.appendingPathComponent(path)
    }
}

// MARK: - Constants

private struct Constant {
    static let baseURL = URL(string: "https://api.tfl.gov.uk")!
    static let stopTypes = "NaptanMetroStation,NaptanRailStation"
    static let modes = "tube"
}

private enum Credentials: String {
    case id = "86bb596d"
    case key = "ad5329c3730e6d8f215bf930fab72bcb"
}
