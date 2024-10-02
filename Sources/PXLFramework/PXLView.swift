//
//  SwiftUIView.swift
//  PXLFramework
//
//  Created by Timothy Dillman on 10/1/24.
//

import SwiftUI
/*
 Provides an invisible view to track screen views or tracking when views appear.
 
 - note: use as `.background` when tracking several views that appear.
 */
public struct PXLView: View {
    @EnvironmentObject var session: PXLSessionObservable
    public var viewID: String
    public var body: some View {
        EmptyView()
            .onAppear {
                Task {
                    await session.logOpen(viewID: viewID)
                }
            }
            .onDisappear {
                Task {
                    await session.logClose(viewID: viewID)
                }
            }
    }
    public init(viewID: String) {
        self.viewID = viewID
    }
}

public class PXLSessionObservable: ObservableObject {
    @Published var ip: String = "getting ip"
    private var session: PXLSessionImpl
    
    public init(session: PXLSessionImpl = .init(configuration: .init(apiURL: ""))) {
        self.session = session
        Task { @MainActor in
            self.ip = await self.session.configuration.ip
        }
    }
    
    public func logOpen(viewID: String) async {
        await session.logEvent(pxlEvent: PXLViewEvent.viewOpen(viewID: viewID))
    }
    
    public func logClose(viewID: String) async {
        await session.logEvent(pxlEvent: PXLViewEvent.viewClose(viewID: viewID))
    }
}

#Preview {
    PXLView(viewID: "test_view").environmentObject(PXLSessionObservable())
}
