//
//  Recorder.swift
//  screen mirroring
//
//  Created by Tomasz Baranowicz on 17/05/2024.
//

import AVFoundation
import Photos
import SwiftUI
import Cocoa
import Foundation
import AVKit
import CoreMediaIO
import CoreMedia
import SwiftUI
import Cocoa

import CoreGraphics
import ImageIO

class Recorder: NSObject, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    
    @Published var session = AVCaptureSession() // session is now @Published
    @Published var isRecording = false
    
    @Published var availableCameras = [AVCaptureDevice]()
    @Published var selectedCameraIndex = 1
    @Published var selectedCameraIsFrontFace = false
    private var currentVideoInput: AVCaptureDeviceInput?
    
    @Published var availableMicrophones = [AVCaptureDevice]()
    @Published var selectedMicrophoneIndex = 0
    private var currentAudioInput: AVCaptureDeviceInput?
    
    private let movieOutput = AVCaptureMovieFileOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    @Published var frame: CGImage?
    private let frameManager = FrameManager()
    private let context = CIContext()
    
    @Published var cameras: [AVCaptureDevice] = []
    @Published var selectedDevice: SelectedStreamingDevice?
//    @Published var session = AVCaptureSession()
//    @Published var currentVideoInput: AVCaptureDeviceInput?
    
    override init() {
        super.init()

        setupSubscriptions()
    }
    
    private func showError(errorMessage: String) {
//        DispatchQueue.main.async {
//            self.showAlert = true
//            self.alertMessage = errorMessage
//        }
    }
    
    private func showToast(toastMessage: String) {
//        DispatchQueue.main.async {
//            self.showToast = true
//            self.toastMessage = toastMessage
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.showToast = false
//            }
//        }
    }
    
    func startRecorder() {
        print("START SESSION")
        
        setupSession()
        startSession()
    }
    
    func stopRecorder() {
        print("STOP SESSION")
//        stopRecording()
        stopSession()
    }
    
    private func startSession() {
        DispatchQueue(label: "com.tombaranowicz.SessionQ").async {
            self.session.startRunning()
        }
    }
    
    private func stopSession() {
        DispatchQueue(label: "com.tombaranowicz.SessionQ").async {
            self.session.stopRunning()
        }
    }
    
    func setupSubscriptions() {
      frameManager.$current
        .receive(on: RunLoop.main)
        .compactMap { buffer in
            guard let image = CGImage.create(from: buffer) else {
              return nil
            }

            let ciImage = CIImage(cgImage: image)
                        
          return self.context.createCGImage(ciImage, from: ciImage.extent)
        }
        .assign(to: &$frame)
    }
    
    func setupSession() {
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                let videoOutputQueue = DispatchQueue(
                    label: "com.tombaranowicz.VideoOutputQ",
                    qos: .userInitiated,
                    attributes: [],
                    autoreleaseFrequency: .workItem)
                
                self.videoOutput.setSampleBufferDelegate(self.frameManager, queue: videoOutputQueue)
                
                if self.session.canAddOutput(self.movieOutput) {
                    self.session.addOutput(self.movieOutput)
                }

                if self.session.canAddOutput(self.videoOutput) {
                    self.session.addOutput(self.videoOutput)
                    
                    self.videoOutput.videoSettings =
                    [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                }
                
                DispatchQueue.main.async {
                    self.setupCamera()
                }
            } else {
                self.showError(errorMessage: "Camera access is required to use Video Recorder.")
            }
        }
    }
    
    func setupCamera() {
        enableDalDevices()
        reloadCameras()

        NotificationCenter.default.addObserver(
            forName: .AVCaptureDeviceWasConnected,
            object: nil,
            queue: nil
        ) { notification in
            self.reloadCameras()
        }
        
        NotificationCenter.default.addObserver(
            forName: .AVCaptureDeviceWasDisconnected,
            object: nil,
            queue: nil
        ) { notification in
            self.reloadCameras()
        }
    }
    
//    func startRecording() {
//        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("video.mp4") else { return }
//        if movieOutput.isRecording == false {
//            if FileManager.default.fileExists(atPath: url.path) {
//                try? FileManager.default.removeItem(at: url)
//            }
//            movieOutput.startRecording(to: url, recordingDelegate: self)
//            isRecording = true
//        }
//    }
//    
//    func stopRecording() {
//        if movieOutput.isRecording {
//            movieOutput.stopRecording()
//            isRecording = false
//        }
//    }
//    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        // Handle actions when recording starts
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // Check for recording error
        if let error = error {
            print("Error recording: \(error.localizedDescription)")
            return
        }
        
        // Save video to Photos
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { saved, error in
            if saved {
                self.showToast(toastMessage: "Successfully saved video to Photos.")
            } else if let error = error {
                self.showError(errorMessage: "Error saving video to Photos: \(error.localizedDescription)")
            }
        }
    }
    
    func reloadCameras() {
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
            selectCamera(captureDevice: captureDevice)
        } else {
            selectCamera(captureDevice: nil)
        }
    }
    
    private func enableDalDevices() {
        var property = CMIOObjectPropertyAddress(mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices), mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal), mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain))
        var allow : UInt32 = 1
        let sizeOfAllow = MemoryLayout.size(ofValue: allow)
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &property, 0, nil, UInt32(sizeOfAllow), &allow)
    }
    
    func selectCamera(captureDevice: AVCaptureDevice?) {
        
        if (captureDevice != nil) {
            
            let connectedDevices = listConnectedDevices()
            let serialNumber = captureDevice!.uniqueID.replacingOccurrences(of: "-", with: "")
            
            let usbDevice = connectedDevices.filter { $0.serial == serialNumber }.first
            
            if (usbDevice != nil) {
                selectedDevice = SelectedStreamingDevice(captureDevice: captureDevice!, usbDevice: usbDevice!)
                frame = nil
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
            
            
            let videoOutputQueue = DispatchQueue(
                                label: "com.tombaranowicz.VideoOutputQ",
                                qos: .userInitiated,
                                attributes: [],
                                autoreleaseFrequency: .workItem)
            
            self.videoOutput.setSampleBufferDelegate(self.frameManager, queue: videoOutputQueue)
            
            if session.canAddOutput(self.videoOutput)
            {
                session.addOutput(self.videoOutput)
                
                self.videoOutput.videoSettings =
                [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            }
            
            session.startRunning()

        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
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
}

class FrameManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {

  @Published var current: CVPixelBuffer?

    func captureOutput(
      _ output: AVCaptureOutput,
      didOutput sampleBuffer: CMSampleBuffer,
      from connection: AVCaptureConnection
    ) {
      if let buffer = sampleBuffer.imageBuffer {
        DispatchQueue.main.async {
          self.current = buffer
        }
      }
    }
}

