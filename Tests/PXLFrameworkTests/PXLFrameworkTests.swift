import Testing
import Foundation
@testable import PXLFramework
import PorkChop

@Test func testInitializeConfiguration() async {
    
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, "{}".data(using: .utf8))
    }
    let networking = createMockNetworking()
    let pxlConfig = PXLConfiguration(apiURL: "http://test.com", networkProvider: networking)
    let service = PXLSessionImpl(configuration: pxlConfig)
    #expect(service.configuration.apiURL == "http://test.com")
    await service.logEvent(pxlEvent: PXLApplifeCycleEvent.appOpen())
}

@Test func handlesErrorWhenNetworkFails() async {
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!
        return (response, "{}".data(using: .utf8))
    }
    let networking = createMockNetworking()
    let pxlConfig = PXLConfiguration(apiURL: "http://test.com", networkProvider: networking)
    let service = PXLSessionImpl(configuration: pxlConfig)
    #expect(service.configuration.apiURL == "http://test.com")
    await service.logEvent(pxlEvent: PXLApplifeCycleEvent.appOpen())
}

@Test func convertsToURLQueryParameters() throws {
    class MockEvent: PXLEvents {
        var test: String = "test"
    }
    
    let mock = MockEvent()
    do {
        let result = try mock.toEventURLParameters()
        #expect(result.count > 0)
        let firstResult = result.first!
        #expect(firstResult.value == "test")
    } catch {
        throw error
    }
}

func createMockNetworking() -> PRKChopNetworking {
    let networking = PRKChopNetworking()
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: configuration)
    networking.session = session
    return networking
}

class MockURLProtocol: URLProtocol {
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
