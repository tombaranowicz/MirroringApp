//
//  ContentView.swift
//  screen mirroring
//
//  Created by Tomasz Baranowicz on 23/04/2024.
//

import SwiftUI
import AVFoundation
import Cocoa
import Foundation
import AVKit
import CoreMediaIO
import CoreMedia
import SwiftUI
import Cocoa

struct iPadBezelView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20) // Adjust this padding to match the bezel thickness
            .background(Color.black) // Bezel color, typically black
            .cornerRadius(20) // Adjust the corner radius to match the iPad's rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2) // Optional border stroke for effect
            )
            .shadow(radius: 10) // Optional shadow for depth effect
    }
}

extension View {
    func iPadBezel() -> some View {
        iPadBezelView {
            self
        }
    }
}

//// Define a preference key to store the size of the view
//struct ViewSizeKey: PreferenceKey {
//    static var defaultValue: CGSize = .zero
//
//    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
//        value = nextValue()
//    }
//}

struct ContentView: View {
    
    @StateObject private var recorder = Recorder()
    @State private var viewSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if recorder.selectedDevice != nil {
                    if let image = recorder.frame {
                        ZStack {
                            if recorder.selectedDevice!.usbDevice.type == .iPad {
                                iPadFrameView(image: image, screenSize: recorder.selectedDevice!.screenSize, viewSize: self.viewSize)
                                    .cornerRadius(10)
                                    .iPadBezel()
                                    .padding(10)
                            } else {
                                iPhoneFrameView(image: image, screenSize: recorder.selectedDevice!.screenSize)
                                    .cornerRadius(recorder.selectedDevice!.screenSize.cornerRadius)
                                
                                if let bezelImage = NSImage(named: "\(recorder.selectedDevice!.deviceName) - \(image.height > image.width ? "Portrait" : "Landscape")") {
                                    Image(nsImage: bezelImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: bezelImage.size.width/recorder.selectedDevice!.screenSize.scaleFactor, height: bezelImage.size.height/recorder.selectedDevice!.screenSize.scaleFactor)
                                }
                            }
                        }
                        .background(TransparentWindow())
                    } else {
                        VStack {
                            Text("Preparing device:\n\n\(recorder.selectedDevice!.captureDevice.localizedName)\n\n\nPlease make sure it's connected and unlocked.").frame(width: 400, height: 400).multilineTextAlignment(.center)
                            ProgressView() // This creates a spinner
                        }.padding()
                    }
                } else {
                    VStack {
                        Text("Please connect the device").frame(width: 200, height: 50)
                        ProgressView() // This creates a spinner
                    }.padding(50)//.background(TransparentWindow())
                }
            }
            .onChange(of: recorder.selectedDevice) { newDevice in
                if let device = newDevice {
                    recorder.setupCamera(device: device)
                }
            }
            .onAppear {
                self.recorder.startRecorder()
            }
            .navigationTitle((recorder.selectedDevice != nil) ? recorder.selectedDevice!.captureDevice.localizedName : "")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        ForEach(recorder.cameras, id: \.self) { camera in
                            Button(camera.localizedName) {
                                recorder.selectCamera(captureDevice: camera)
                            }
                        }
                    } label: {
                        Image(systemName: "ipad.and.iphone")
                            .padding(.horizontal, 4)
                    }
                }
            }.onAppear {
                viewSize = geometry.size
                print("new size1 \(viewSize)")
            }.onChange(of: geometry.size) { newSize in
                viewSize = newSize
                print("new size \(viewSize)")
            }
        }
    }
}

struct iPhoneFrameView: View {
    var image: CGImage
    var screenSize: ScreenSize
    private let label = Text("Video feed")
    
    var body: some View {
        Image(image, scale: screenSize.scaleFactor, orientation: .up, label: label)
    }
}

struct iPadFrameView: View {
    var image: CGImage
    var screenSize: ScreenSize
    var viewSize: CGSize
    private let label = Text("Video feed")
    
    var body: some View {
        Image(image, scale: calculateScaleFactor(innerSize: viewSize, outerSize: CGSize(width: image.width+80, height: image.height+80)), orientation: .up, label: label)
    }
    
    func calculateScaleFactor(innerSize: CGSize, outerSize: CGSize) -> CGFloat {
        let widthScale = outerSize.width / innerSize.width
        let heightScale = outerSize.height / innerSize.height
        return max(widthScale, heightScale)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

