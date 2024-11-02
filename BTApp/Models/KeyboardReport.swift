//
//  KeyboardReport.swift
//  HIDController
//
//  Created by Jesus Macbook on 18/10/24.
//
import Foundation
import CoreBluetooth

struct KeyboardReport {
    static let reportId: UInt8 = 0x02
    private var modifiers: UInt8 = 0
    private var reserved: UInt8 = 0
    private var keyCodes: [UInt8] = [0, 0, 0, 0, 0, 0]
    
    init(modifiers: UInt8 = 0, keyCodes: [UInt8] = []) {
        self.modifiers = modifiers
        self.keyCodes = Array(keyCodes.prefix(6)) + Array(repeating: 0, count: max(0, 6 - keyCodes.count))
    }
    
    func getData() -> Data {
        var report = [UInt8](repeating: 0, count: 8)
        report[0] = KeyboardReport.reportId
        report[1] = modifiers
        report[2] = reserved
        for (index, keyCode) in keyCodes.prefix(6).enumerated() {
            report[2 + index] = keyCode
        }
        return Data(report)
    }
}

// MARK: - Modifier Keys
extension KeyboardReport {
    struct Modifier {
        static let leftControl: UInt8 = 0x01
        static let leftShift: UInt8 = 0x02
        static let leftAlt: UInt8 = 0x04
        static let leftGUI: UInt8 = 0x08
        static let rightControl: UInt8 = 0x10
        static let rightShift: UInt8 = 0x20
        static let rightAlt: UInt8 = 0x40
        static let rightGUI: UInt8 = 0x80
    }
}

// MARK: - Common Key Codes
extension KeyboardReport {
    struct KeyCode {
        static let a: UInt8 = 0x04
        static let b: UInt8 = 0x05
        static let c: UInt8 = 0x06
        // Add more key codes as needed
        
        static func from(ascii: UInt8) -> UInt8? {
            switch ascii {
            case 97...122: // a-z
                return ascii - 93
            case 65...90:  // A-Z
                return ascii - 61
            default:
                return nil
            }
        }
    }
}
