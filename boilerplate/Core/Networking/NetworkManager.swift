//
//  NetworkManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation

/// Protocol for network operations - allows for testing and abstraction
protocol NetworkManaging {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
    func stream(_ endpoint: Endpoint, onChunk: @escaping (Data) -> Void) async throws
}

/// Centralized networking layer
class NetworkManager: NetworkManaging {
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - Request Methods
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await request(endpoint)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }
    
    func request(_ endpoint: Endpoint) async throws -> Data {
        let urlRequest = try buildURLRequest(from: endpoint)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            
            return data
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error.localizedDescription)
        }
    }
    
    func stream(_ endpoint: Endpoint, onChunk: @escaping (Data) -> Void) async throws {
        let urlRequest = try buildURLRequest(from: endpoint)
        
        // TODO: Implement proper streaming with URLSessionDataDelegate
        // For now, use async bytes iterator
        let (bytes, response) = try await session.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        var buffer = Data()
        
        for try await byte in bytes {
            buffer.append(byte)
            
            // TODO: Implement proper chunking logic based on SSE or newlines
            // For SSE: look for "data: " prefix and "\n\n" delimiter
            if buffer.count >= 1024 || buffer.last == 10 { // 10 = newline
                onChunk(buffer)
                buffer = Data()
            }
        }
        
        // Send remaining data
        if !buffer.isEmpty {
            onChunk(buffer)
        }
    }
    
    // MARK: - Helper Methods
    
    private func buildURLRequest(from endpoint: Endpoint) throws -> URLRequest {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = endpoint.timeout
        
        // Add headers
        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body
        if let body = endpoint.body {
            request.httpBody = body
        }
        
        return request
    }
}

// MARK: - Endpoint Protocol

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    var timeout: TimeInterval { get }
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
    
    var timeout: TimeInterval {
        return 30.0
    }
    
    var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(String)
    case httpError(statusCode: Int)
    case decodingFailed(String)
    case noInternetConnection
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingFailed(let message):
            return "Failed to decode response: \(message)"
        case .noInternetConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        }
    }
}
