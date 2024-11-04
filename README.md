# Image Guard

![guard2](https://github.com/user-attachments/assets/f47ed26a-b623-4b19-a299-f589b1424695)

Image Guard is a macOS application built with SwiftUI that helps protect sensitive information in images by detecting and censoring emails, phone numbers, and URLs.

## Features

- **Drag & Drop Support**: Easily load images by dropping them into the application
- **Smart Detection**: Automatically identifies:
  - Email addresses
  - Phone numbers
  - URLs
- **Selective Censoring**: 
  - Toggle detection for different types of sensitive data
  - Individually select which detected items to censor
  - Real-time preview of censored image
- **Export Options**: Save the censored image in common formats (PNG, JPG, JPEG)

## Technical Highlights

### Vision Framework Integration
The app uses Apple's Vision framework (`VNRecognizeTextRequest`) for accurate text recognition in images, combined with `NSDataDetector` for identifying specific patterns in the detected text.

### Key Components

1. **SensitiveData Structure**
   ```
   struct SensitiveData: Hashable, Identifiable {
    let id = UUID()
    let type: DataType
    var selected: Bool
    let boundingBox: CGRect
    let text: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
   }

2. **Detection Pipeline**
- Text recognition using Vision framework
- Pattern matching using NSDataDetector
- Real-time updating of censored regions

3. **Image Processing**
- Non-destructive editing: original image is preserved
- Censoring implemented using black rectangles over detected regions
- Coordinates conversion from normalized to image space

## Usage

1. Launch the application
2. Drop an image or use "Load New Image" button
3. Toggle which types of sensitive data to detect
4. Select/deselect specific items to censor
5. Save the censored image using "Save Censored Image"

## Requirements

- macOS (SwiftUI-based application)
- Access to Vision framework
- Image input capabilities

## Privacy

All processing is done locally on your machine - no data is sent to external servers.

## Technical Notes

- Uses `NSImage` for macOS compatibility
- Implements custom coordinate transformation for accurate censoring
- Real-time preview updates when toggling detection options
