//
//  HIDDescriptor.swift
//  HIDController
//
//  Created by Jesus Macbook on 18/10/24.
//
import Foundation
import CoreBluetooth

struct HIDDescriptor {
    // Convert uint8 array to Data
    static var reportMap: Data {
        return Data([
            // Mouse TLC
            0x05, 0x01,        // Usage Page (Generic Desktop)
            0x09, 0x02,        // Usage (Mouse)
            0xA1, 0x01,        // Collection (Application)
            0x09, 0x01,        //   Usage (Pointer)
            0xA1, 0x00,        //   Collection (Physical)
            0x05, 0x09,        //     Usage Page (Button)
            0x19, 0x01,        //     Usage Minimum (1)
            0x29, 0x03,        //     Usage Maximum (3)
            0x15, 0x00,        //     Logical Minimum (0)
            0x25, 0x01,        //     Logical Maximum (1)
            0x95, 0x03,        //     Report Count (3)
            0x75, 0x01,        //     Report Size (1)
            0x81, 0x02,        //     Input (Data, Variable, Absolute)
            0x95, 0x01,        //     Report Count (1)
            0x75, 0x05,        //     Report Size (5)
            0x81, 0x01,        //     Input (Constant)
            0x05, 0x01,        //     Usage Page (Generic Desktop)
            0x09, 0x30,        //     Usage (X)
            0x09, 0x31,        //     Usage (Y)
            0x15, 0x81,        //     Logical Minimum (-127)
            0x25, 0x7F,        //     Logical Maximum (127)
            0x75, 0x08,        //     Report Size (8)
            0x95, 0x02,        //     Report Count (2)
            0x81, 0x06,        //     Input (Data, Variable, Relative)
            0xC0,              //   End Collection
            0xC0,              // End Collection
            
            // Keyboard TLC
            0x05, 0x01,        // Usage Page (Generic Desktop)
            0x09, 0x06,        // Usage (Keyboard)
            0xA1, 0x01,        // Collection (Application)
            0x05, 0x07,        //   Usage Page (Key Codes)
            0x19, 0xE0,        //   Usage Minimum (224)
            0x29, 0xE7,        //   Usage Maximum (231)
            0x15, 0x00,        //   Logical Minimum (0)
            0x25, 0x01,        //   Logical Maximum (1)
            0x75, 0x01,        //   Report Size (1)
            0x95, 0x08,        //   Report Count (8)
            0x81, 0x02,        //   Input (Data, Variable, Absolute)
            0x95, 0x01,        //   Report Count (1)
            0x75, 0x08,        //   Report Size (8)
            0x81, 0x01,        //   Input (Constant)
            0x95, 0x06,        //   Report Count (6)
            0x75, 0x08,        //   Report Size (8)
            0x15, 0x00,        //   Logical Minimum (0)
            0x25, 0x65,        //   Logical Maximum (101)
            0x05, 0x07,        //   Usage Page (Key Codes)
            0x19, 0x00,        //   Usage Minimum (0)
            0x29, 0x65,        //   Usage Maximum (101)
            0x81, 0x00,        //   Input (Data, Array)
            0xC0               // End Collection
        ])
    }
    
    // Helper methods for accessing specific parts of the descriptor
    static var mouseDescriptor: Data {
        return Data([
            0x05, 0x01,        // Usage Page (Generic Desktop)
            0x09, 0x02,        // Usage (Mouse)
            0xA1, 0x01,        // Collection (Application)
            0x09, 0x01,        //   Usage (Pointer)
            0xA1, 0x00,        //   Collection (Physical)
            0x05, 0x09,        //     Usage Page (Button)
            0x19, 0x01,        //     Usage Minimum (1)
            0x29, 0x03,        //     Usage Maximum (3)
            0x15, 0x00,        //     Logical Minimum (0)
            0x25, 0x01,        //     Logical Maximum (1)
            0x95, 0x03,        //     Report Count (3)
            0x75, 0x01,        //     Report Size (1)
            0x81, 0x02,        //     Input (Data, Variable, Absolute)
            0x95, 0x01,        //     Report Count (1)
            0x75, 0x05,        //     Report Size (5)
            0x81, 0x01,        //     Input (Constant)
            0x05, 0x01,        //     Usage Page (Generic Desktop)
            0x09, 0x30,        //     Usage (X)
            0x09, 0x31,        //     Usage (Y)
            0x15, 0x81,        //     Logical Minimum (-127)
            0x25, 0x7F,        //     Logical Maximum (127)
            0x75, 0x08,        //     Report Size (8)
            0x95, 0x02,        //     Report Count (2)
            0x81, 0x06,        //     Input (Data, Variable, Relative)
            0xC0,              //   End Collection
            0xC0               // End Collection
        ])
    }
    
    static var keyboardDescriptor: Data {
        return Data([
            0x05, 0x01,        // Usage Page (Generic Desktop)
            0x09, 0x06,        // Usage (Keyboard)
            0xA1, 0x01,        // Collection (Application)
            0x05, 0x07,        //   Usage Page (Key Codes)
            0x19, 0xE0,        //   Usage Minimum (224)
            0x29, 0xE7,        //   Usage Maximum (231)
            0x15, 0x00,        //   Logical Minimum (0)
            0x25, 0x01,        //   Logical Maximum (1)
            0x75, 0x01,        //   Report Size (1)
            0x95, 0x08,        //   Report Count (8)
            0x81, 0x02,        //   Input (Data, Variable, Absolute)
            0x95, 0x01,        //   Report Count (1)
            0x75, 0x08,        //   Report Size (8)
            0x81, 0x01,        //   Input (Constant)
            0x95, 0x06,        //   Report Count (6)
            0x75, 0x08,        //   Report Size (8)
            0x15, 0x00,        //   Logical Minimum (0)
            0x25, 0x65,        //   Logical Maximum (101)
            0x05, 0x07,        //   Usage Page (Key Codes)
            0x19, 0x00,        //   Usage Minimum (0)
            0x29, 0x65,        //   Usage Maximum (101)
            0x81, 0x00,        //   Input (Data, Array)
            0xC0               // End Collection
        ])
    }
}

// MARK: - HID Constants
extension HIDDescriptor {
    enum UsagePage: UInt8 {
        case genericDesktop = 0x01
        case keyboard = 0x07
        case button = 0x09
    }
    
    enum Usage: UInt8 {
        case pointer = 0x01
        case mouse = 0x02
        case keyboard = 0x06
        case x = 0x30
        case y = 0x31
    }
    
    enum Collection: UInt8 {
        case application = 0x01
        case physical = 0x00
    }
}

// MARK: - Helper Methods
extension HIDDescriptor {
    static func validate() -> Bool {
        // Simple validation of descriptor data
        return reportMap.count > 0 &&
               mouseDescriptor.count > 0 &&
               keyboardDescriptor.count > 0
    }
    
    static var reportMapLength: Int {
        return reportMap.count
    }
}
