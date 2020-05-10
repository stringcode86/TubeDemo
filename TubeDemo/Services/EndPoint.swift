//
//  EndPoint.swift
//  TubeDemo
//
//  Created by stringCode on 09/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation

enum EndPoint {
    case nearByStations(lat: Float, lon: Float, radius: Int)
    case arrivals(id: String)
}

extension EndPoint {

    func URL() -> URL {
        switch self {

        case let .nearByStations(lat, lon, radius):
            var urlComps = URLComponents(
                url: stopPointURL(),
                resolvingAgainstBaseURL: false
            )
            urlComps?.queryItems = [
                URLQueryItem(name: "lat", value: "\(lat)"),
                URLQueryItem(name: "lon", value: "\(lon)"),
                URLQueryItem(name: "radius", value: "\(radius)"),
                URLQueryItem(name: "stoptypes", value: "NaptanMetroStation,NaptanRailStation"),
                URLQueryItem(name: "modes", value: "tube"),
            ] + credentialsQueryItems()
            return urlComps!.url!

        case let .arrivals(id):
            var urlComps = URLComponents(
                url: stopPointURL().appendingPathComponent("\(id)/Arrivals"),
                resolvingAgainstBaseURL: false
            )
            urlComps?.queryItems = [
                URLQueryItem(name: "modes", value: "tube")
            ] + credentialsQueryItems()
            return urlComps!.url!
        }
    }
}

extension EndPoint {

    private func baseURL() -> URL {
        return Foundation.URL(string: "https://api.tfl.gov.uk")!
    }

    private func stopPointURL() -> URL {
        return baseURL().appendingPathComponent("Stoppoint")
    }

    private func credentialsQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "app_id", value: Credentials.id.rawValue),
            URLQueryItem(name: "app_key", value: Credentials.key.rawValue)
        ]
    }
}
