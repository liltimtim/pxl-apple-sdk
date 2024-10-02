//
//  PXLEvents.swift
//  PXLFramework
//
//  Created by Timothy Dillman on 10/1/24.
//

import Foundation

public protocol PXLEvents: Encodable {
    func toEventURLParameters() throws -> [URLQueryItem]
}

public extension PXLEvents {
    func toEventURLParameters() throws -> [URLQueryItem] {
        let data = try JSONEncoder().encode(self)
        guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw PXLError.invalidJSON
        }
        return dict.map { URLQueryItem(name: $0.key, value: "\($0.value)")}
    }
}

public enum PXLError: Error {
    case invalidJSON
}

public struct PXLApplifeCycleEvent: PXLEvents {
    let type: String = "applifecycle"
    let event: String
    let eventDescription: String?

    private enum EventType: String {
        case appOpen = "appopen"
        case appClose = "appclose"
        case appSuspend = "appsuspend"
        case appResume = "appresume"
    }
    
    private init(type: EventType, eventDescription: String?) {
        self.eventDescription = eventDescription
        self.event = type.rawValue
    }
    /// Lifecycle event app opened.
    public static func appOpen(with description: String? = nil) -> PXLEvents {
        return PXLApplifeCycleEvent(type: .appOpen, eventDescription: description)
    }
    /// Lifecycle event app closed.
    public static func appClose(with description: String? = nil) -> PXLEvents {
        return PXLApplifeCycleEvent(type: .appClose, eventDescription: description)
    }
    /// Lifecycle event app resume
    public static func appResume(with description: String? = nil) -> PXLEvents {
        return PXLApplifeCycleEvent(type: .appResume, eventDescription: description)
    }
    /// Lifecycle event app suspend
    public static func appSuspend(with description: String? = nil) -> PXLEvents {
        return PXLApplifeCycleEvent(type: .appSuspend, eventDescription: description)
    }
}

public struct PXLViewEvent: PXLEvents {
    let type: String = "view"
    let event: String
    let eventDescription: String?
    let viewID: String
    
    private enum EventType: String {
        case viewOpen = "viewopen"
        case viewClose = "viewclose"
    }
    
    private init(event: EventType, viewID: String, description: String?) {
        self.event = event.rawValue
        self.viewID = viewID
        self.eventDescription = description
    }
    
    public static func viewOpen(viewID: String, description: String? = nil) -> PXLViewEvent {
        PXLViewEvent(event: .viewOpen, viewID: viewID, description: description)
    }
    
    public static func viewClose(viewID: String, description: String? = nil) -> PXLViewEvent {
        PXLViewEvent(event: .viewClose, viewID: viewID, description: description)
    }
}
