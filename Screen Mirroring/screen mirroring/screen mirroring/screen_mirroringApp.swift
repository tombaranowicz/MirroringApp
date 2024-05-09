//
//  screen_mirroringApp.swift
//  screen mirroring
//
//  Created by Tomasz Baranowicz on 23/04/2024.
//

import SwiftUI

@main
struct screen_mirroringApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                
//                .background(TransparentWindow())
//                .navigationTitle("My Title")
                .presentedWindowToolbarStyle(.expanded)
//                .navigationSubtitle("Subtitle")
//                .toolbarBackground(.white)
//                        .toolbarColorScheme(.dark)
//                        .toolbar { CustomToolbarView() }
                        
        }
        .windowResizabilityContentSize()
        
//        .windowStyle(HiddenTitleBarWindowStyle()) // Hide the title bar for a borderless window
//        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle()) // Hide the toolbar
    }
}

struct CustomToolbarView: ToolbarContent {
    @State private var isButtonEnabled = false
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                // Add action for button
            }) {
                Image(systemName: "square.and.pencil")
            }
            .disabled(!isButtonEnabled)
        }
        
        ToolbarItem(placement: .secondaryAction) {
            Button(action: {
                // Add action for button
            }) {
                Image(systemName: "gearshape.fill")
            }
        }
        
        ToolbarItem(placement: .status) {
            Toggle("Enable Button", isOn: $isButtonEnabled)
        }
    }
}

struct VisualEffect: NSViewRepresentable {
   func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
   func updateNSView(_ nsView: NSView, context: Context) { }
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
