# iOS Screen Mirroring App

![2](https://github.com/user-attachments/assets/3d5fa8fb-784c-40ce-ab82-cab57530e248)
![3](https://github.com/user-attachments/assets/c02fe44a-60c9-4a55-9dd0-d12c57f1f99f)
![5](https://github.com/user-attachments/assets/7d358c91-bd2b-4d44-be2e-66e2e4e8ebf1)
![7](https://github.com/user-attachments/assets/bbd7c786-b7b3-42a0-83ef-bac932c0304f)
![6](https://github.com/user-attachments/assets/31077505-af14-474e-adc8-6584f7991bf5)

A macOS application that enables screen mirroring and recording from iOS devices using Swift and AVFoundation framework.

## Features

- 📱 Real-time screen mirroring from iOS devices (iPhone/iPad)
- 🎥 Video capture and recording capabilities
- 🎙️ Audio input support
- 🔄 Hot-plug device detection
- 📸 Frame-by-frame video processing
- 💾 Video saving to Photos library

## Key Components

### Recorder Class

The main controller class that handles device management and video capture. Key functionalities include:

- Device discovery and management
- Video session configuration
- Frame processing
- Recording controls

### Device Management

```
func reloadCameras() {
// Discovers external capture devices
let devices = AVCaptureDevice.DiscoverySession(
deviceTypes: [.external],
mediaType: nil,
position: .unspecified
).devices
// Filters for compatible devices
cameras = devices.filter({ camera in
return camera.activeFormat.mediaType.rawValue == "muxx"
})
}
```



### Frame Processing

The `FrameManager` class handles real-time frame processing:
- Captures video frames from the device
- Converts frames to CGImage format
- Publishes frames for display using SwiftUI

### USB Device Detection

The app includes sophisticated USB device detection that:
- Monitors system USB ports for iOS devices
- Parses device information (type, serial number, version)
- Automatically connects to newly plugged devices

## Technical Details

### Requirements
- macOS (version TBD)
- iOS device with USB connection
- Camera/Screen recording permissions

### Key Frameworks
- AVFoundation
- CoreMediaIO
- CoreMedia
- Photos
- SwiftUI

### Architecture
The app follows a reactive pattern using SwiftUI and Combine:
- `@Published` properties for reactive UI updates
- Delegate pattern for capture session management
- Queue management for optimal performance

## Implementation Notes

The app uses several important techniques:
1. DAL (Digital Audio/Video Lab) device enablement for screen capture
2. Separate dispatch queues for video processing
3. Memory-efficient frame buffer management
4. Automatic device discovery and configuration

---

This project demonstrates advanced usage of Apple's media frameworks for creating a robust screen mirroring solution.
