//
//  NetworkEndPoint.swift
//  TubeDemo
//
//  Created by stringCode on 11/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation

/// Intended to be implements by any API end point
protocol NetworkEndPoint {
    var url: URL { get }
    var method: HttpMethod { get }
    var queryItems: Dictionary<String, String>? { get }
    var headers: Dictionary<String, String>? { get }
    var body: Dictionary<String, Any>? { get }
    var caching: URLRequest.CachePolicy { get }
    var timeout: TimeInterval { get }
}

/// Default implementation of protocol values
extension NetworkEndPoint {
    
    var method: HttpMethod {
        return .GET
    }

    var queryItems: Dictionary<String, String>? {
        return nil
    }

    var headers: Dictionary<String, String>? {
        return nil
    }

    var body: Dictionary<String, Any>? {
        return nil
    }

    var caching: URLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    var timeout: TimeInterval {
        return 65
    }
}

/// Http methos
enum HttpMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}
