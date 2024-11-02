//
//  MouseReport.swift
//  HIDController
//
//  Created by Jesus Macbook on 18/10/24.
//

import Foundation
import CoreBluetooth

struct MouseReport {
    static let reportId: UInt8 = 0x01
    private var buttons: UInt8 = 0
    private var x: Int8 = 0
    private var y: Int8 = 0
    
    init(buttons: UInt8 = 0, deltaX: Int8 = 0, deltaY: Int8 = 0) {
        self.buttons = buttons
        self.x = deltaX
        self.y = deltaY
    }
    
    mutating func setButton(_ button: Int, pressed: Bool) {
        if pressed {
            buttons |= UInt8(1 << button)
        } else {
            buttons &= ~UInt8(1 << button)
        }
    }
    
    func getData() -> Data {
        var report = [UInt8](repeating: 0, count: 4)
        report[0] = MouseReport.reportId
        report[1] = buttons
        report[2] = UInt8(bitPattern: x)
        report[3] = UInt8(bitPattern: y)
        return Data(report)
    }
}

// MARK: - Button Constants
extension MouseReport {
    struct Button {
        static let left = 0
        static let right = 1
        static let middle = 2
    }
}
