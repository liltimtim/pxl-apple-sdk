//
//  PXLConfiguration.swift
//  PXLFramework
//
//  Created by Timothy Dillman on 10/1/24.
//

import Foundation
import PorkChop
public struct PXLConfiguration {
    let apiURL: URL
    let networkProvider: PRKChopNetworking
    let cache: UserDefaults
    var sessionID: String {
        return createOrGetSessionID()
    }
    var ip: String {
        get async {
            await backgroundFetchIP()
        }
    }
    
    init(apiURL: String,
         networkProvider: PRKChopNetworking = .init(),
         cache: UserDefaults = .init(suiteName: "com.pxl.framework") ?? .standard) {
        self.apiURL = URL(stringLiteral: apiURL)
        self.networkProvider = networkProvider
        self.cache = cache
        // clear any cache to get new IP on init
        self.clearCache()
    }
    
    private func backgroundFetchIP() async -> String {
        do {
            guard let cachedIP = getIPFromCache() else {
                // no IP fetch from remote
                let ip = try await getIP()
                storeIP(ip: ip)
                return ip
            }
            return cachedIP
        } catch {
            return "ip-not-found"
        }
    }
    
    private func getIP() async throws -> String {
        let request = URLRequest(url: URL(string: "https://api.ipify.org?format=json")!)
        let response = try await networkProvider.make(for: request)
        let json = try JSONDecoder().decode([String: String].self, from: response)
        return json["ip"] ?? "ip-not-found"
    }
    
    private func storeIP(ip: String) {
        cache.set(ip, forKey: "storedIP")
    }
    
    private func getIPFromCache() -> String? {
        if let ip = cache.string(forKey: "storedIP") {
            return ip
        } else {
            return nil
        }
    }
    
    private func clearCache() {
        cache.removeObject(forKey: "storedIP")
    }
    
    private func createOrGetSessionID() -> String {
        guard let sessionID = cache.string(forKey: "sessionID") else {
            let sessionID = UUID().uuidString
            cache.set(sessionID, forKey: "sessionID")
            return sessionID
        }
        return sessionID
    }
}
