//
//  BluetoothHIDService.swift
//  HIDController
//
//  Created by Jesus Macbook on 18/10/24.
//NSBluetoothAlwaysUsageDescription


import CoreBluetooth
import SwiftUI
import os.log

class BluetoothService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var selectedPeripheral: CBPeripheral?
    @Published var permissionGranted = false
    @Published var errorMessage: String?
    @Published var isAdvertising = false
    
    // MARK: - Private Properties
    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    private var hidService: CBMutableService?
    private var reportCharacteristic: CBMutableCharacteristic?
    private let logger = Logger(subsystem: "com.yourapp.HIDController", category: "Bluetooth")
    
    // Service UUIDs
    private let hidServiceUUID = CBUUID(string: "1812")  // Standard HID Service
    private let reportMapCharUUID = CBUUID(string: "2A4B")
    private let reportCharUUID = CBUUID(string: "2A4D")
    
    // MARK: - Initialization
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard centralManager?.state == .poweredOn else {
            errorMessage = "Bluetooth is not powered on"
            return
        }
        
        isScanning = true
        discoveredDevices.removeAll()
        centralManager?.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.stopScanning()
        }
    }
    
    func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        selectedPeripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        if let peripheral = selectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        stopAdvertising()
    }
    
    // HID Functionality
    func startAdvertising() {
        logger.info("Starting advertising")
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [hidServiceUUID],
            CBAdvertisementDataLocalNameKey: "iOS HID Device"
        ]
        peripheralManager?.startAdvertising(advertisementData)
        isAdvertising = true
    }
    
    func stopAdvertising() {
        logger.info("Stopping advertising")
        peripheralManager?.stopAdvertising()
        isAdvertising = false
    }
    
    func sendMouseMovement(deltaX: Int8, deltaY: Int8) {
        guard isConnected else { return }
        
        var report = [UInt8](repeating: 0, count: 3)
        report[1] = UInt8(bitPattern: deltaX)
        report[2] = UInt8(bitPattern: deltaY)
        
        let reportData = Data(report)
        peripheralManager?.updateValue(
            reportData,
            for: reportCharacteristic!,
            onSubscribedCentrals: nil
        )
    }
    
    func sendMouseClick() {
        guard isConnected else { return }
        
        var report = [UInt8](repeating: 0, count: 3)
        report[0] = 0x01  // Left button pressed
        
        peripheralManager?.updateValue(
            Data(report),
            for: reportCharacteristic!,
            onSubscribedCentrals: nil
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            report[0] = 0x00  // Button released
            self.peripheralManager?.updateValue(
                Data(report),
                for: self.reportCharacteristic!,
                onSubscribedCentrals: nil
            )
        }
    }
    
    func sendKeyPress(keyCode: UInt8, pressed: Bool) {
        guard isConnected else { return }
        
        var report = [UInt8](repeating: 0, count: 8)
        if pressed {
            report[2] = keyCode
        }
        
        let reportData = Data(report)
        peripheralManager?.updateValue(
            reportData,
            for: reportCharacteristic!,
            onSubscribedCentrals: nil
        )
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            permissionGranted = true
        case .poweredOff:
            errorMessage = "Bluetooth is turned off"
            permissionGranted = false
        case .unauthorized:
            errorMessage = "Bluetooth permission denied"
            permissionGranted = false
        case .unsupported:
            errorMessage = "BLE is not supported"
            permissionGranted = false
        default:
            errorMessage = "Bluetooth is not available"
            permissionGranted = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                       advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let deviceName = peripheral.name, !deviceName.isEmpty {
            if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                discoveredDevices.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        selectedPeripheral = nil
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BluetoothService: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        logger.info("Peripheral manager state updated: \(peripheral.state.rawValue)")
        
        switch peripheral.state {
        case .poweredOn:
            setupHIDService()
        case .poweredOff:
            isConnected = false
            isAdvertising = false
        case .unauthorized:
            errorMessage = "Bluetooth permission denied"
        case .unsupported:
            errorMessage = "Bluetooth LE is not supported"
        default:
            break
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        isConnected = true
        logger.info("Central subscribed to characteristic")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        isConnected = false
        logger.info("Central unsubscribed from characteristic")
    }
    
    private func setupHIDService() {
        logger.info("Setting up HID Service")
        
        // Create HID Service
        hidService = CBMutableService(type: hidServiceUUID, primary: true)
        
        // Report Map Characteristic
        let reportMapCharacteristic = CBMutableCharacteristic(
            type: reportMapCharUUID,
            properties: .read,
            value: HIDDescriptor.reportMap,
            permissions: .readable
        )
        
        // Report Characteristic
        reportCharacteristic = CBMutableCharacteristic(
            type: reportCharUUID,
            properties: [.read, .notify, .writeWithoutResponse],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        hidService?.characteristics = [reportMapCharacteristic, reportCharacteristic!]
        peripheralManager?.add(hidService!)
    }
}
