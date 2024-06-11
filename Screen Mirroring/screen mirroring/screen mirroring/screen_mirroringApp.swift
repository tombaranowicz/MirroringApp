//
//  screen_mirroringApp.swift
//  screen mirroring
//
//  Created by Tomasz Baranowicz on 23/04/2024.
//

import SwiftUI

@main
struct screen_mirroringApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class TransparentWindowView: NSView {
    override func viewDidMoveToWindow() {
        window?.backgroundColor = .clear
        super.viewDidMoveToWindow()
    }
}

struct TransparentWindow: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView { return TransparentWindowView() }
    func updateNSView(_ nsView: NSView, context: Context) { }
}

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}

struct AppMenu: View {
    func action1() {}
    func action2() {}
    func action3() {}
    
    var body: some View {
        Button(action: action1, label: { Text("Action 1") })
        Button(action: action2, label: { Text("Action 2") })
        
        Divider()
        
        Button(action: action3, label: { Text("Action 3") })
    }
}
