//
//  PXLSession.swift
//  PXLFramework
//
//  Created by Timothy Dillman on 10/1/24.
//

import PorkChop
import Foundation

public protocol PXLSession {
    var configuration: PXLConfiguration { get }
    init(configuration: PXLConfiguration)
    func logEvent(pxlEvent: PXLEvents) async
}

public struct PXLSessionImpl: PXLSession {
    public let configuration: PXLConfiguration
    
    public init(configuration: PXLConfiguration) {
        self.configuration = configuration
    }
    
    public func logEvent(pxlEvent: PXLEvents) async {
        do {
            var params = try pxlEvent.toEventURLParameters()
            let ip = await configuration.ip
            let session = configuration.sessionID
            params.append(URLQueryItem(name: "ip", value: ip))
            params.append(.init(name: "session", value: session))
            let url = configuration.apiURL.appending(queryItems: params)
            _ = try await configuration.networkProvider.make(for: configuration.networkProvider.createRequest(url: url, httpMethod: .get, body: PRKChopEmptyBody()))
        } catch {
            print(error.localizedDescription)
        }
    }
}
