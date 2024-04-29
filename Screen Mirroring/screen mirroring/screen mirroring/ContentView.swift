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

enum DeviceType {
    case iPad
    case iPhone
}

struct ScreenSize {
    let width: Int
    let height: Int
}

struct ConnectedDevice {
    let minor: Int
    let major: Int
    let serial: String
    let type: DeviceType
}

struct SelectedStreamingDevice: Equatable {
    let captureDevice: AVCaptureDevice
    let usbDevice: ConnectedDevice
    let screenSize: ScreenSize
    
    init(captureDevice: AVCaptureDevice, usbDevice: ConnectedDevice) {
        self.captureDevice = captureDevice
        self.usbDevice = usbDevice
    
        var width: Int = 100
        var height: Int = 100
        
        if (self.usbDevice.type == .iPhone) {
            if let screenSizeString = Utils.resolutionList["iPhone\(self.usbDevice.major),\(self.usbDevice.minor)"] {
                let components = screenSizeString.split(separator: "x")

                print("components \(components)")
                
                if components.count == 2 {
                    width = Int(components[0])!
                    height = Int(components[1])!
                }
            }
        }
        
        self.screenSize = ScreenSize(width: width/3, height: height/3)
    }
    
    static func ==(lhs: SelectedStreamingDevice, rhs: SelectedStreamingDevice) -> Bool {
        return lhs.captureDevice == rhs.captureDevice
    }
}

struct ContentView: View {
    @State private var selectedDevice: SelectedStreamingDevice?
    @State private var cameras: [AVCaptureDevice] = []
    @State private var session = AVCaptureSession()
    @State private var currentVideoInput: AVCaptureDeviceInput?

    
    var body: some View {
        VStack {
            if let selectedDevice {
                CameraPreviewView(session: session).frame(width: CGFloat(selectedDevice.screenSize.width), height: CGFloat(selectedDevice.screenSize.height))
            }
        }.onChange(of: selectedDevice) { newDevice in
            
//            print("on change was called \(newDevice)")
            
            if let device = newDevice {
                setupCamera(device: device)
            }
        }
        .onAppear {
            enableDalDevices()
            loadCameras()

            NotificationCenter.default.addObserver(
                forName: .AVCaptureDeviceWasConnected,
                object: nil,
                queue: nil
            ) { notification in
                
                guard let device = notification.object as? AVCaptureDevice else {
                        return
                    }
                
                loadCameras()
            }
        }
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

    func loadCameras() {
        
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
