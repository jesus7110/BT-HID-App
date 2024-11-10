//
//  KeyCodes.swift
//  BTApp
//
//  Created by Jesus Macbook on 10/11/24.
//


import Foundation

// Key Codes based on USB HID Usage Tables
enum KeyCodes {
    // Modifier masks
    static let leftControl: UInt8 = 0xE0
    static let leftShift: UInt8 = 0xE1
    static let leftAlt: UInt8 = 0xE2  // Option key on Mac
    static let leftGUI: UInt8 = 0xE3  // Command key on Mac, Windows key on PC
    static let rightControl: UInt8 = 0xE4
    static let rightShift: UInt8 = 0xE5
    static let rightAlt: UInt8 = 0xE6
    static let rightGUI: UInt8 = 0xE7
    
    // Special keys
    static let enter: UInt8 = 0x28
    static let escape: UInt8 = 0x29
    static let backspace: UInt8 = 0x2A
    static let tab: UInt8 = 0x2B
    static let space: UInt8 = 0x2C
    static let capsLock: UInt8 = 0x39
    
    // Function keys
    static let f1: UInt8 = 0x3A
    static let f2: UInt8 = 0x3B
    static let f3: UInt8 = 0x3C
    static let f4: UInt8 = 0x3D
    static let f5: UInt8 = 0x3E
    static let f6: UInt8 = 0x3F
    static let f7: UInt8 = 0x40
    static let f8: UInt8 = 0x41
    static let f9: UInt8 = 0x42
    static let f10: UInt8 = 0x43
    static let f11: UInt8 = 0x44
    static let f12: UInt8 = 0x45
    
    // Standard letter keys (a=4, b=5, etc.)
    static let letterKeyCodes: [Character: UInt8] = {
        var codes: [Character: UInt8] = [:]
        for (index, letter) in "abcdefghijklmnopqrstuvwxyz".enumerated() {
            codes[letter] = UInt8(index + 4)
        }
        return codes
    }()
    
    // Number keys
    static let numberKeyCodes: [Character: UInt8] = {
        var codes: [Character: UInt8] = [:]
        for (index, number) in "123456789".enumerated() {
            codes[number] = UInt8(index + 0x1E)
        }
        codes["0"] = 0x27
        return codes
    }()
    
    // Get keycode for any character
    static func getKeyCode(for char: Character) -> UInt8? {
        let lowercaseChar = char.lowercased().first ?? char
        
        // Check letters
        if let letterCode = letterKeyCodes[lowercaseChar] {
            return letterCode
        }
        
        // Check numbers
        if let numberCode = numberKeyCodes[char] {
            return numberCode
        }
        
        // Check special characters
        switch char {
        case " ": return space
        case "\n": return enter
        case "\t": return tab
        case ".": return 0x37
        case ",": return 0x36
        case "-": return 0x2D
        case "=": return 0x2E
        case "[": return 0x2F
        case "]": return 0x30
        case "\\": return 0x31
        case ";": return 0x33
        case "'": return 0x34
        case "`": return 0x35
        case "/": return 0x38
        default: return nil
        }
    }
    
    // Get modifier mask for a keycode
    static func isModifier(_ keyCode: UInt8) -> Bool {
        switch keyCode {
        case leftControl, leftShift, leftAlt, leftGUI,
             rightControl, rightShift, rightAlt, rightGUI:
            return true
        default:
            return false
        }
    }
}

// Extension for human-readable descriptions
extension KeyCodes {
    static func getDescription(for keyCode: UInt8) -> String {
        switch keyCode {
        case leftControl: return "Left Control"
        case leftShift: return "Left Shift"
        case leftAlt: return "Left Alt/Option"
        case leftGUI: return "Left GUI/Command"
        case rightControl: return "Right Control"
        case rightShift: return "Right Shift"
        case rightAlt: return "Right Alt/Option"
        case rightGUI: return "Right GUI/Command"
        case enter: return "Enter"
        case escape: return "Escape"
        case backspace: return "Backspace"
        case tab: return "Tab"
        case space: return "Space"
        case capsLock: return "Caps Lock"
        default:
            if let letter = letterKeyCodes.first(where: { $0.value == keyCode })?.key {
                return String(letter).uppercased()
            }
            if let number = numberKeyCodes.first(where: { $0.value == keyCode })?.key {
                return String(number)
            }
            return "Unknown Key"
        }
    }
}