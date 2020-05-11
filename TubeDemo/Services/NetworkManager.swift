//
//  NetworkManger.swift
//  TubeDemo
//
//  Created by stringCode on 09/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation

#if DEBUG
private let debug = false
#else
private let debug = false
#endif

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

typealias DataResponceBlock = (_ data: Data?, _ error: Error?) -> Void

/// Simple network manger implentation. Uses `NetworkEndPoint` protocol
/// to pass data to network framework (`URLSession`) that executes the request.
class NetworkManager {
    
    static var `default` = NetworkManager()

    /// Performs networks request with `URLSession.shared`
    class func request(_ endPoint: NetworkEndPoint, completion: @escaping DataResponceBlock) {
        NetworkManager.default.request(endPoint, completion: completion)
    }
    
    /// Performs networks request with `URLSession.shared`
    func request(_ endPoint: NetworkEndPoint, completion: @escaping DataResponceBlock) {
        let session = URLSession.shared
        let request = self.request(endPoint)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.log(request, response: response, data: data, error: error)
            completion(data, error)
        }
        task.resume()
    }
    
    /// Constructs request from `NetworkEndPoint`
    private func request(_ endPoint: NetworkEndPoint) -> URLRequest {
        let url = endPoint.url.apending(endPoint.queryItems)
        let caching = endPoint.caching
        let timeout = endPoint.timeout
        var request = URLRequest(url: url, cachePolicy: caching, timeoutInterval: timeout)
        request.httpMethod = endPoint.method.rawValue
        request.allHTTPHeaderFields = endPoint.headers
        if let body = endPoint.body {
            request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        }
        return request
    }

    /// debugPrints response
    private func log(_ request: URLRequest, response: URLResponse?, data: Data?, error: Error?) {
        guard debug else {
            return
        }
        print("Request: ", request)
        print("Headers: ", request.allHTTPHeaderFields ?? [])
        if let body = request.httpBody {
            print("Body: ", String(data: body, encoding: .utf8) ?? "")
        }
        if let response = response {
            print(response)
        }
        if let string = String(data: data ?? Data(), encoding: .utf8) {
            print(string)
        }
        if let error = error {
            print(error)
        }
    }
}

/// MARK: - URL query items extension

extension URL {
    
    /// Appends `queryItems` to `URL`. In case of failure returns `self`
    func apending(_ queryItems: Dictionary<String, String>?) -> URL {
        guard let queryItems = queryItems else {
            return self
        }
        guard var components = URLComponents(string: absoluteString) else {
            return self
        }
        var items = components.queryItems ?? []
        for (key, val) in queryItems {
            items.append(URLQueryItem(name: key, value: val))
        }
        components.queryItems = items
        return components.url ?? self
    }
}

/// MARK - JSON decoding extension

extension NetworkManager {
    
    class func request<T>(_ ep: NetworkEndPoint, type: T.Type, handler: @escaping (T?, Error?)->()) where T: Decodable {
        self.default.request(ep, type: type, handler: handler)
    }
    
    class func request<T, U>(_ ep: NetworkEndPoint, type: T.Type, errT: U.Type?, handler: @escaping (T?, Error?)->()) where T: Decodable, U: Decodable & Error {
        self.default.request(ep, type: type, errT: errT, handler: handler)
    }
    
    func request<T>(_ ep: NetworkEndPoint, type: T.Type, handler: @escaping (T?, Error?)->()) where T: Decodable {
        request(ep) { (data, error) in
            let (res, err) = JSONDecoder.decode(type, data: data)
            handler(res, error ?? err)
        }
    }
    
    func request<T, U>(_ ep: NetworkEndPoint, type: T.Type, errT: U.Type?, handler: @escaping (T?, Error?)->()) where T: Decodable, U: Decodable & Error {
        request(ep) { (data, error) in
            let (res, err) = JSONDecoder.decode(type, errT: errT, data: data)
            handler(res, error ?? err)
        }
    }
}

/// JSONDecoder extension whose goal is to make json parsing less verbose
/// instead of try catch, this extension offers returning tuple.
extension JSONDecoder {
    
    private struct NoType: Error, Decodable { }
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.rfc3339)
        return decoder
    }()
    
    /// Decodes `type` if posible. If failt to decode `type` returns `MsgError.msg`
    class func decode<T>(_ type: T.Type, data: Data?) -> (T?, Error?) where T: Decodable {
        return self.default.decode(type, errT: NoType.self, data: data)
    }
    
    /// Decodes `type` if posible. If failt to decode `type`, tries to decode
    /// `errT` (error type) if provided. Otherwise returns `MsgError.msg`
    class func decode<T,U>(_ type: T.Type, errT: U.Type? = nil, data: Data?) -> (T?, Error?) where T: Decodable, U: Decodable & Error {
        return self.default.decode(type, errT: errT, data: data)
    }
    
    /// Decodes `type` if posible. If failt to decode `type` returns `MsgError.msg`
    func decode<T>(_ type: T.Type, data: Data?) -> (T?, Error?) where T: Decodable {
        return decode(type, errT: NoType.self, data: data)
    }
    
    /// Decodes `type` if posible. If failt to decode `type`, tries to decode
    /// `errT` (error type) if provided. Otherwise returns `MsgError.msg`
    func decode<T,U>(_ type: T.Type, errT: U.Type? = nil, data: Data?) -> (T?, Error?) where T: Decodable, U: Decodable & Error {
        guard let data = data else {
            return (nil, MsgError.noData)
        }
        do {
            let result = try decode(type, from: data)
            return (result, nil)
        } catch {
            if let errType = errT, "\(errType)" != "\(NoType.self)" {
                let (err, _) = decode(errType, errT: NoType.self, data: data)
                return (nil, err)
            }
            return (nil, MsgError.msg(error.localizedDescription))
        }
    }
}

/// Generic error message
enum MsgError: Error {
    case msg(_ msg: String)
    case noData
    case unknown
}

extension MsgError: Decodable {
    enum CodingKeys: String, CodingKey {
        case message
    }
    
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            self = .unknown
            return
        }
        if let msg = try? container.decode(String.self, forKey: .message) {
            self = .msg(msg)
            return
        }
        self = .unknown
    }
}

extension MsgError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .msg(let msg):
            return msg
        case .noData:
            return "No data recieved"
        case .unknown:
            return "Unknown error occured"
        }
    }
}
