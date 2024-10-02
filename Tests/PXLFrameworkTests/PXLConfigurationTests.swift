//
//  PXLConfigurationTests.swift
//  PXLFramework
//
//  Created by Timothy Dillman on 10/1/24.
//

import Testing
import Foundation
import PorkChop
@testable import PXLFramework
@Suite struct PXLConfigurationTests {
    @Test func getIPAddress() async {
        let mockNetworking = createMockNetworking()
        let config = PXLConfiguration(apiURL: "http://test.com", networkProvider: mockNetworking, cache: UserDefaults(suiteName: "com.testing.getIPAddress")!)
        MockURLProtocolPXLConfiguration.requestHandler = nil
        MockURLProtocolPXLConfiguration.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = "{ \"ip\": \"127.0.0.1\"}".data(using: .utf8)!
            return (response, data)
        }
        let result = await config.ip
        let cachedResults = await config.ip
        #expect(result == "127.0.0.1")
        #expect(cachedResults == "127.0.0.1")
    }

    @Test func ipNotFound() async {
        
        let mockNetworking = createMockNetworking()
        let config = PXLConfiguration(apiURL: "http://test.com", networkProvider: mockNetworking, cache: UserDefaults(suiteName: "com.testing.ipNotFound")!)
        MockURLProtocolPXLConfiguration.requestHandler = nil
        MockURLProtocolPXLConfiguration.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        let result = await config.ip
        #expect(result == "ip-not-found")
    }

    @Test func getSessionID() {
        let result = PXLConfiguration(apiURL: "http://test.com", cache: UserDefaults(suiteName: "com.getSessionID")!).sessionID
        #expect(result.count == 36)
    }
    
    @Test func getSessionIDCached() {
        let config = PXLConfiguration(apiURL: "http://test.com", cache: UserDefaults(suiteName: "com.getSessionIDCached")!)
        let result = config.sessionID
        let cachedResult = config.sessionID
        #expect(result.count == 36)
        #expect(result == cachedResult)
    }
    
    class MockURLProtocolPXLConfiguration: URLProtocol {
        nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let handler = Self.requestHandler else {
                fatalError("Handler is unavailable")
            }
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading() {
            
        }
    }
    
    func createMockNetworking() -> PRKChopNetworking {
        let networking = PRKChopNetworking()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocolPXLConfiguration.self]
        let session = URLSession(configuration: configuration)
        networking.session = session
        return networking
    }
}

