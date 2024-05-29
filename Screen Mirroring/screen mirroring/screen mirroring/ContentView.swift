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


struct ContentView: View {
    
    @StateObject private var recorder = Recorder()
    
    var body: some View {
        
        VStack {
            if recorder.selectedDevice != nil {
                if let image = recorder.frame {
                    ZStack {
                        FrameView(image: image, screenSize: recorder.selectedDevice!.screenSize)
                            .cornerRadius(recorder.selectedDevice!.screenSize.cornerRadius)
                        
                        if let image = NSImage(named: "\(recorder.selectedDevice!.deviceName) - \(image.height > image.width ? "Portrait" : "Landscape")") {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: image.size.width/recorder.selectedDevice!.screenSize.scaleFactor, height: image.size.height/recorder.selectedDevice!.screenSize.scaleFactor)
                        }
                    }.background(TransparentWindow())
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
        }
    }
}

struct FrameView: View {
    var image: CGImage
    var screenSize: ScreenSize
    private let label = Text("Video feed")
    
    var body: some View {
        Image(image, scale: screenSize.scaleFactor, orientation: .up, label: label)
        //            .cornerRadius(screenSize.cornerRadius/screenSize.scaleFactor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

