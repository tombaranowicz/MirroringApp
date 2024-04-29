import UIKit

var greeting = "Hello, playground"

let output = """
USB:

USB 3.1 Bus:

Host Controller Driver: AppleT8122USBXHCI

USB 3.1 Bus:

Host Controller Driver: AppleT8122USBXHCI

USB 3.1 Bus:

Host Controller Driver: AppleT8122USBXHCI

iPhone:

Product ID: 0x12a8
Vendor ID: 0x05ac (Apple Inc.)
Version: 15.03
Serial Number: 00008120001A19813AE0C01E
Manufacturer: Apple Inc.
Location ID: 0x01100000

USB 3.0 Bus:

Host Controller Driver: AppleUSBXHCIFL1100
PCI Device ID: 0x1100
PCI Revision ID: 0x0010
PCI Vendor ID: 0x1b73

CalDigit Thunderbolt 3 Audio:

Product ID: 0x6533
Vendor ID: 0x2188  (CalDigit)
Version: 1.01
Manufacturer: CalDigit, Inc.
Location ID: 0x03200000

USB 3.0 Bus:

Host Controller Driver: AppleUSBXHCIFL1100
PCI Device ID: 0x1100
PCI Revision ID: 0x0010
PCI Vendor ID: 0x1b73

Card Reader :

Product ID: 0x0747
Vendor ID: 0x2188  (CalDigit)
Version: 10.38
Serial Number: 000000000010
Manufacturer: CalDigit
Location ID: 0x04800000

USB 3.1 Bus:

Host Controller Driver: AppleASMediaUSBXHCI
PCI Device ID: 0x1242
PCI Revision ID: 0x0000
PCI Vendor ID: 0x1b21

Apple Watch Magnetic Charging Cable:

Product ID: 0x0503
Vendor ID: 0x05ac (Apple Inc.)
Version: 21.30
Serial Number: DLC210502K90KWTA9
Manufacturer: Apple Inc.
Location ID: 0x05400000

"""


func parseItem(item: String) {
    
    if(!item.isEmpty && item.contains("Manufacturer: Apple Inc.")) {
        
//        Parse only iPhones and iPads for now.
        if (!item.contains("iPhone") && !item.contains("iPad")) {
            return
        }
        
        print("-------------------")
        print(item)
        
        
        let lines = item.components(separatedBy: "\n")
        for line in lines {
            
        //    print(line.trimmingCharacters(in: .whitespaces))
            if (line.contains("Version")) {
                let components = line.split(separator: ":")
                if components.count == 2 {
                    let numericValueString = components[1].trimmingCharacters(in: .whitespaces)
                    
                    let components = numericValueString.split(separator: ".")

                    // Convert the substrings to integers
                    if components.count == 2, let major = Int(components[0]), let minor = Int(components[1]) {
                        print("Major version: \(major)") // Output: Major version: 15
                        print("Minor version: \(minor)") // Output: Minor version: 3
                    } else {
                        print("Invalid version format")
                    }

                }
            } else if (line.contains("Serial Number")) {
                let components = line.split(separator: ":")
                if components.count == 2 {
                    let numericValueString = components[1].trimmingCharacters(in: .whitespaces)
                    print("Serial Number: \(numericValueString)")
                }
            }
        }

        
        
    }
    
    tempItemString = ""
}

var tempItemString = ""
let lines = output.components(separatedBy: "\n")
for line in lines {
    
//    print(line.trimmingCharacters(in: .whitespaces))
    if (line.contains("USB") && line.contains("Bus")) {
        parseItem(item: tempItemString)
    } else {
        tempItemString.append("\n\(line)")
    }
}

parseItem(item: tempItemString)
