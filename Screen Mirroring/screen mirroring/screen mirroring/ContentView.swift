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
    @State private var selectedCamera: AVCaptureDevice?
    @State private var cameras: [AVCaptureDevice] = []
    @State private var session = AVCaptureSession()
    @State private var currentVideoInput: AVCaptureDeviceInput?
    @State private var connectedDevices: [String] = []
    
    var body: some View {
        VStack {
//            Picker("Camera", selection: $selectedCamera) {
//                ForEach(cameras, id: \.self) { camera in
//                    Text(camera.localizedName).tag(camera as AVCaptureDevice?)
//                }
//            }.onChange(of: selectedCamera) { newCamera in
//                
//                print("on change was called \(newCamera)")
//                
//                if let camera = newCamera {
//                    setupCamera(camera: camera)
//                }
//            }
//            .padding()
//            .onAppear {
//
//                
////                NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: nil) { _ in
////                    print("new camera connected")
//////                               updateAvailableCameras()
////                           }
////                           
////                           NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: nil) { _ in
////                               print("camera disconnected")
//////                               updateAvailableCameras()
////                           }
////                           
//                enableDalDevices()
//                loadCameras()
//            }

//            if let camera = selectedCamera {
//                CameraPreview(camera: camera)
//                    .frame(width: 400, height: 300)
//            }
//            if let session = session {
                CameraPreviewView(session: session)
                    .frame(width: 400, height: 850)
//            } else {
//                Text("No camera available")
//                    .foregroundColor(.red)
//            }
            
//            List(connectedDevices, id: \.self) { deviceName in
//                            Text(deviceName)
//                        }
        }.onChange(of: selectedCamera) { newCamera in
            
            print("on change was called \(newCamera)")
            
            
            if let camera = newCamera {
                setupCamera(camera: camera)
            }
        }
        .onAppear {
            enableDalDevices()
            loadCameras()
            
            // Add observer for AVCaptureDeviceWasConnectedNotification
                        NotificationCenter.default.addObserver(
                            forName: .AVCaptureDeviceWasConnected,
                            object: nil,
                            queue: nil
                        ) { notification in
                            
                            guard let device = notification.object as? AVCaptureDevice else {
                                    return
                                }
                                
//                            modelID / iOS Device
                            let modelName = device.manufacturer
                                print("Connected device model: \(modelName)")
                            
                            print("CAPTURE DEVICE WAS CONNECTED CALLED \(notification)")
                            loadCameras()
                            
                            listConnectedDevices()
                        }
        }
    }
    
    
    func listConnectedDevices() {
        let task = Process()
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["SPUSBDataType"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
//            print(output)
            
            var usbItems: [USBItem] = []
            
            let lines = output.components(separatedBy: "\n")
            for line in lines {
                
                print(line.trimmingCharacters(in: .whitespaces))
                if (line.contains("USB") && line.contains("Bus")) {
//                    usbItems.
                } else {
                    
                
                }
//                if line.hasPrefix("USB") {
//                    // Parse property line
//                    let components = line.trimmingCharacters(in: .whitespaces).components(separatedBy: ":")
//                    if components.count == 2 {
//                        let key = components[0].trimmingCharacters(in: .whitespaces)
//                        let value = components[1].trimmingCharacters(in: .whitespaces)
//                        currentUSBItemProperties[key] = value
//                    }
//                } else if line.hasPrefix("  ") {
//                    // Parse USB item line
//                    if !currentUSBItemName.isEmpty {
//                        let usbItem = USBItem(name: currentUSBItemName, properties: currentUSBItemProperties)
//                        usbItems.append(usbItem)
//                    }
//                    currentUSBItemName = line.trimmingCharacters(in: .whitespaces)
//                    currentUSBItemProperties = [:]
//                }
            }

//            // Add the last USB item
//            if !currentUSBItemName.isEmpty {
//                let usbItem = USBItem(name: currentUSBItemName, properties: currentUSBItemProperties)
//                usbItems.append(usbItem)
//            }
            
            
//            print("FOUND IPHONE \(output.components(separatedBy: "\n").filter { $0.contains("iPhone") } ?? [])")
            
//            let usbItems = parseUSBItems(from: output)
//            for usbItem in usbItems {
//                print("Name: \(usbItem.name)")
//                print("Properties: \(usbItem.properties)")
//                print("")
//            }
        }
    }
    

    
    private func enableDalDevices() {
        var property = CMIOObjectPropertyAddress(mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices), mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal), mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain))
        var allow : UInt32 = 1
        let sizeOfAllow = MemoryLayout.size(ofValue: allow)
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &property, 0, nil, UInt32(sizeOfAllow), &allow)
    }

    func loadCameras() {
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
        selectedCamera = cameras.first
        
        print("SELECTED \(selectedCamera?.position)")
    }
    
    func setupCamera(camera: AVCaptureDevice) {
        // Remove previous if set.
        if currentVideoInput != nil {
            session.removeInput(currentVideoInput!)
            currentVideoInput = nil
        }
        
        
//        let formats = camera.formats
//
//        // Print information about each format
//        for format in formats {
//            
//            print("FORMAT \(format)")
//            
//            let formatDescription = format.formatDescription
//            
//            
//            // Check if the format description is a video format description
//            if CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Muxed {
//                // Get the extensions from the muxed format description
//                let extensions = CMFormatDescriptionGetExtensions(formatDescription)! as NSDictionary
//                print("EXTENSIONS \(extensions)")
//                
//                extensions.forEach { key, value in
//                    
//                    print("CHKEC KEY \(key)")
//                    // Check if the value is an array of CMFormatDescription
//                    if let formatDescriptions = value as? [CMFormatDescription] {
//                        // Iterate over each format description
//                        formatDescriptions.forEach { formatDescription in
//                            // Check if the format description is a video format description
//                            if CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Video {
//                                // Get the dimensions (size) from the video format description
//                                let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
//                                
//                                // Print the dimensions
//                                print("Video Dimensions: \(dimensions.width)x\(dimensions.height)")
//                            }
//                        }
//                    }
//                }
//            } else {
//                print("Not a muxx format description")
//            }
            

//            // Get the extensions from the muxed format description
//            let extensions = CMFormatDescriptionGetExtensions(formatDescription)
//            print("EXTENSIONS \(extensions)")
////            as NSDictionary
////
//            // Iterate over each extension
//            extensions.forEach { key, value in
//                // Check if the value is an array of CMFormatDescription
//                if let formatDescriptions = value as? [CMFormatDescription] {
//                    // Iterate over each format description
//                    formatDescriptions.forEach { formatDescription in
//                        // Check if the format description is a video format description
//                        if CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Video {
//                            // Get the dimensions (size) from the video format description
//                            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
//
//                            // Print the dimensions
//                            print("Video Dimensions: \(dimensions.width)x\(dimensions.height)")
//                        }
//                    }
//                }
//            }
                
        do {
            let input = try AVCaptureDeviceInput(device: camera)
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

//struct CameraPreview: NSViewRepresentable {
//    let camera: AVCaptureDevice
//
//    func makeNSView(context: Context) -> NSView {
//        let previewView = NSView()
//
//        let captureSession = AVCaptureSession()
//        print("")
//        guard let input = try? AVCaptureDeviceInput(device: camera) else { return previewView }
//        print("recognizes camera")
//        captureSession.addInput(input)
//        captureSession.startRunning()
//
//        print("PREVIEW BOUNDS \(previewView.bounds)")
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
//        previewView.layer?.addSublayer(previewLayer)
//
//        return previewView
//    }
//
//    func updateNSView(_ nsView: NSView, context: Context) {}
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//import SwiftUI
//import AVFoundation
//
//struct CameraPreviewView: NSViewRepresentable {
//    let session: AVCaptureSession
//    
//    func makeNSView(context: Context) -> NSView {
//        let view = NSView()
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = view.bounds
//        view.layer = previewLayer
//        view.wantsLayer = true
//        
//        return view
//    }
//    
//    func updateNSView(_ nsView: NSView, context: Context) {
//        // No updates needed for now
//    }
//}

//struct ContentView: View {
//    let session = AVCaptureSession()
//    
//    var body: some View {
//        VStack {
//            CameraPreviewView(session: session)
//                .frame(width: 400, height: 300)
//                .onAppear {
//                    self.setupCamera()
//                }
//        }
//    }
//    
//    private func setupCamera() {
//        guard let camera = AVCaptureDevice.default(for: .video) else {
//            print("No camera available")
//            return
//        }
//        
//        do {
//            let input = try AVCaptureDeviceInput(device: camera)
//            session.addInput(input)
//            session.startRunning()
//        } catch {
//            print("Error setting up camera: \(error.localizedDescription)")
//        }
//    }
//}


struct USBItem {
    let name: String
    let properties: [String: String]
}

func parseUSBItems(from string: String) -> [USBItem] {
    var usbItems: [USBItem] = []
    var currentUSBItemName = ""
    var currentUSBItemProperties: [String: String] = [:]

    let lines = string.components(separatedBy: "\n")
    for line in lines {
        if line.hasPrefix("    ") {
            // Parse property line
            let components = line.trimmingCharacters(in: .whitespaces).components(separatedBy: ":")
            if components.count == 2 {
                let key = components[0].trimmingCharacters(in: .whitespaces)
                let value = components[1].trimmingCharacters(in: .whitespaces)
                currentUSBItemProperties[key] = value
            }
        } else if line.hasPrefix("  ") {
            // Parse USB item line
            if !currentUSBItemName.isEmpty {
                let usbItem = USBItem(name: currentUSBItemName, properties: currentUSBItemProperties)
                usbItems.append(usbItem)
            }
            currentUSBItemName = line.trimmingCharacters(in: .whitespaces)
            currentUSBItemProperties = [:]
        }
    }

    // Add the last USB item
    if !currentUSBItemName.isEmpty {
        let usbItem = USBItem(name: currentUSBItemName, properties: currentUSBItemProperties)
        usbItems.append(usbItem)
    }

    return usbItems
}
