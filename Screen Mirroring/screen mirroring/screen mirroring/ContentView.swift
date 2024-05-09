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

struct ContentView: View {
    @State private var selectedDevice: SelectedStreamingDevice?
    @State private var cameras: [AVCaptureDevice] = []
    @State private var session = AVCaptureSession()
    @State private var currentVideoInput: AVCaptureDeviceInput?

    
    var body: some View {
        
        VStack {
            if let selectedDevice {
                ZStack {
                    CameraPreviewView(session: session)
                        .frame(width: CGFloat(selectedDevice.screenSize.width), height: CGFloat(selectedDevice.screenSize.height))
                        .cornerRadius(selectedDevice.screenSize.cornerRadius) // Set the corner radius here
                    
                    Image(.iPhone14ProMaxSpaceBlackPortrait)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: CGFloat(1450/3.01), height: CGFloat(2936/3.01))
                }.background(TransparentWindow())
            } else {
                VStack {
                    Text("Please connect the device").frame(width: 200, height: 50)
                    ProgressView() // This creates a spinner
                }.padding(50)
            }
        }.onChange(of: selectedDevice) { newDevice in
            
//            print("on change was called \(newDevice)")
            
            if let device = newDevice {
                setupCamera(device: device)
            }
        }
        .onAppear {
            enableDalDevices()
            reloadCameras()

            NotificationCenter.default.addObserver(
                forName: .AVCaptureDeviceWasConnected,
                object: nil,
                queue: nil
            ) { notification in
                reloadCameras()
            }
            
            NotificationCenter.default.addObserver(
                forName: .AVCaptureDeviceWasDisconnected,
                object: nil,
                queue: nil
            ) { notification in
                reloadCameras()
            }
        }
        .navigationTitle((selectedDevice != nil) ? selectedDevice!.captureDevice.localizedName : "")

//        .toolbar {
//                    ToolbarItem(placement: .primaryAction) {
//                        Button("Button 1") {
//                            // Action for Button 1
//                        }
//                    }
//                    
//                    ToolbarItem(placement: .primaryAction) {
//                        Button("Button 2") {
//                            // Action for Button 2
//                        }
//                    }
//                    
//                    ToolbarItem(placement: .primaryAction) {
//                        Button("Button 3") {
//                            // Action for Button 3
//                        }
//                    }
//                }
    }
    
    func listConnectedDevices() -> [ConnectedDevice] {
        let task = Process()
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["SPUSBDataType"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        var tempArray: [ConnectedDevice] = []
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            
//            print(output)
            
            var tempItemString = ""
            var emptyLines = 0
            var foundDevice = false
            let lines = output.components(separatedBy: "\n")
            for line in lines {
                
                if (line.contains("iPhone") || line.contains("iPad")) {
                    foundDevice = true
                }
                
                if (foundDevice) {
                    tempItemString.append("\n\(line)")
                }
                
                if (line.isEmpty && foundDevice) {
                    emptyLines += 1
                }
                
                if (emptyLines == 2) {
                    if let parsedDevice = parseItem(item: tempItemString) {
//                        print("parsed device \(parsedDevice)")
                        tempArray.append(parsedDevice)
                    }
                    foundDevice = false
                    tempItemString = ""
                    emptyLines = 0
                }
            }
        }
        
        return tempArray
    }
    
    private func parseItem(item: String) -> ConnectedDevice? {
        
        var minor: Int?
        var major: Int?
        var serial: String?
        var type: DeviceType?
        
            print("-------------------")
            print(item)
            
            let lines = item.components(separatedBy: "\n")
            for line in lines {
                
                if (line.contains("iPhone")) {
                    type = .iPhone
                } else if (line.contains("iPad")) {
                    type = .iPad
                } else if (line.contains("Version")) {
                    let components = line.split(separator: ":")
                    if components.count == 2 {
                        let numericValueString = components[1].trimmingCharacters(in: .whitespaces)
                        
                        let components = numericValueString.split(separator: ".")

                        // Convert the substrings to integers
                        if components.count == 2 {
                            major = Int(components[0])
                            minor = Int(components[1])
                        } else {
                            print("Invalid version format")
                        }
                    }
                } else if (line.contains("Serial Number")) {
                    let components = line.split(separator: ":")
                    if components.count == 2 {
                        serial = components[1].trimmingCharacters(in: .whitespaces)
                    }
                }
            }
        
        if (minor != nil && major != nil && serial != nil && type != nil){
            let connectedDevice = ConnectedDevice(minor: minor!, major: major!, serial: serial!, type: type!)
            return connectedDevice
        }
        
        return nil
    }
    
    private func enableDalDevices() {
        var property = CMIOObjectPropertyAddress(mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices), mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal), mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain))
        var allow : UInt32 = 1
        let sizeOfAllow = MemoryLayout.size(ofValue: allow)
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &property, 0, nil, UInt32(sizeOfAllow), &allow)
    }

    func reloadCameras() {
        
        let connectedDevices = listConnectedDevices()
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.external], mediaType: nil, position: .unspecified).devices
        
//        isContinuityCamera = false
//        manufacturer = "Apple Inc."
//        camera.activeFormat.mediaType.rawValue = "muxx"
        
        print("FOUND DEVICES \(devices)")
        
        
//        for camera in devices{
//            print("CAMERA \(camera.description) ---- \(camera.activeFormat.)") //CAMERA Apple Inc.
//        }
        
        cameras = devices.filter({ camera in
            return camera.activeFormat.mediaType.rawValue == "muxx"
        })
        
        print("FOUND DEVICES FILTERED \(cameras)")
        
        
        
        if (cameras.count > 0) {
            let captureDevice = cameras.first!
            let serialNumber = captureDevice.uniqueID.replacingOccurrences(of: "-", with: "")
            
            let usbDevice = connectedDevices.filter { $0.serial == serialNumber }.first
            
            if (usbDevice != nil) {
                selectedDevice = SelectedStreamingDevice(captureDevice: captureDevice, usbDevice: usbDevice!)
            }
        } else {
            selectedDevice = nil
        }
    }
    
    func setupCamera(device: SelectedStreamingDevice) {
        // Remove previous if set.
        if currentVideoInput != nil {
            session.removeInput(currentVideoInput!)
            currentVideoInput = nil
        }

        do {
            let input = try AVCaptureDeviceInput(device: device.captureDevice)
            session.addInput(input)
            currentVideoInput = input
            session.startRunning()
            
//            print("SETUP CAMERA \(camera.) - \(camera.modelID)")
            
            
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
}

struct CameraPreviewView: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer = previewLayer
        view.wantsLayer = true
        
        print("Preview Layer Size:", previewLayer.bounds.size)
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // No updates needed for now
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
