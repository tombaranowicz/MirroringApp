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
//    @State private var selectedDevice: SelectedStreamingDevice?
//    @State private var cameras: [AVCaptureDevice] = []
//    @State private var session = AVCaptureSession()
//    @State private var currentVideoInput: AVCaptureDeviceInput?

    @StateObject private var recorder = Recorder()
    
    var body: some View {
        
        VStack {
            if recorder.selectedDevice != nil {
                ZStack {
                    FrameView(image: recorder.frame)
                }.background(TransparentWindow())
            } else {
                VStack {
                    Text("Please connect the device").frame(width: 200, height: 50)
                    ProgressView() // This creates a spinner
                }.padding(50).background(TransparentWindow())
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
    var image: CGImage?
    private let label = Text("Video feed")
    
    
    var body: some View {
        if let image = image {
//            GeometryReader { geometry in
            Image(image, scale: 2.0, orientation: .up, label: label)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(
//                        width: 200,//geometry.size.width,
//                        height: 200,//geometry.size.height,
//                        alignment: .center)
//                    .clipped()
//            }
        } else {
            EmptyView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

