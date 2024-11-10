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
    
    //session info
    
    private var currentSessionId: String?
    private var connectedCentral: CBCentral?
    private var activeSessions: [CBCentral: SessionInfo] = [:]
    @Published var sessionStatus: String = "No Active Session"
    
    
    // Session Info Structure
    struct SessionInfo {
        let id: String
        let timestamp: Date
        let deviceName: String
        var lastActivity: Date
        
        var debugDescription: String {
            """
            Session ID: \(id)
            Device: \(deviceName)
            Connected: \(timestamp.formatted())
            Last Activity: \(lastActivity.formatted())
            Active Duration: \(Int(lastActivity.timeIntervalSince(timestamp))) seconds
            """
        }
    }
    
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
    
//    func connectToDevice(_ peripheral: CBPeripheral) {
//        selectedPeripheral = peripheral
//        centralManager?.connect(peripheral, options: nil)
//    }
    

//    
//    func disconnect() {
//        if let peripheral = selectedPeripheral {
//            centralManager?.cancelPeripheralConnection(peripheral)
//        }
//        stopAdvertising()
//    }
    
    // In the BluetoothService class
    func connectToDevice(_ peripheral: CBPeripheral) {
        logger.info("Attempting to connect to peripheral: \(peripheral.identifier)")
        selectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager?.connect(peripheral, options: [
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
            CBConnectPeripheralOptionNotifyOnNotificationKey: true
        ])
    }

    func disconnect() {
        logger.info("Initiating disconnect")
        if let peripheral = selectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        stopAdvertising()
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.selectedPeripheral = nil
        }
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
//extension BluetoothService: CBCentralManagerDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        switch central.state {
//        case .poweredOn:
//            permissionGranted = true
//        case .poweredOff:
//            errorMessage = "Bluetooth is turned off"
//            permissionGranted = false
//        case .unauthorized:
//            errorMessage = "Bluetooth permission denied"
//            permissionGranted = false
//        case .unsupported:
//            errorMessage = "BLE is not supported"
//            permissionGranted = false
//        default:
//            errorMessage = "Bluetooth is not available"
//            permissionGranted = false
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
//                       advertisementData: [String: Any], rssi RSSI: NSNumber) {
//        if let deviceName = peripheral.name, !deviceName.isEmpty {
//            if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
//                discoveredDevices.append(peripheral)
//            }
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        isConnected = true
//        peripheral.delegate = self
//        peripheral.discoverServices(nil)
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        isConnected = false
//        selectedPeripheral = nil
//    }
//}


// MARK: - CBCentralManagerDelegate
extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.info("Central manager state updated: \(central.state.rawValue)")
        
        switch central.state {
        case .poweredOn:
            permissionGranted = true
        case .poweredOff:
            errorMessage = "Bluetooth is turned off"
            permissionGranted = false
            isConnected = false
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
        logger.info("Discovered peripheral: \(peripheral.identifier)")
        
        if let deviceName = peripheral.name, !deviceName.isEmpty {
            DispatchQueue.main.async {
                if !self.discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                    self.discoveredDevices.append(peripheral)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.info("Connected to peripheral: \(peripheral.identifier)")
        
        DispatchQueue.main.async {
            self.isConnected = true
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.error("Failed to connect to peripheral: \(peripheral.identifier), error: \(String(describing: error))")
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.selectedPeripheral = nil
            self.errorMessage = "Failed to connect: \(error?.localizedDescription ?? "Unknown error")"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.info("Disconnected from peripheral: \(peripheral.identifier)")
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.selectedPeripheral = nil
            if let error = error {
                self.errorMessage = "Disconnected: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - CBPeripheralDelegate
//extension BluetoothService: CBPeripheralDelegate {
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard let services = peripheral.services else { return }
//        
//        for service in services {
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
//}

// MARK: - CBPeripheralDelegate
extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        logger.info("Services modified for peripheral: \(peripheral.identifier)")
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            logger.error("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            logger.error("No services found")
            return
        }
        
        logger.info("Discovered \(services.count) services")
        
        for service in services {
            logger.info("Discovering characteristics for service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            logger.error("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            logger.error("No characteristics found")
            return
        }
        
        logger.info("Discovered \(characteristics.count) characteristics for service: \(service.uuid)")
        
        for characteristic in characteristics {
            logger.info("Characteristic discovered: \(characteristic.uuid)")
            
            // Subscribe to notifications if the characteristic supports it
            if characteristic.properties.contains(.notify) {
                logger.info("Subscribing to characteristic: \(characteristic.uuid)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            // Read the value if the characteristic is readable
            if characteristic.properties.contains(.read) {
                logger.info("Reading value for characteristic: \(characteristic.uuid)")
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logger.error("Error updating characteristic value: \(error.localizedDescription)")
            return
        }
        
        logger.info("Value updated for characteristic: \(characteristic.uuid)")
        if let value = characteristic.value {
            logger.info("New value: \(value.map { String(format: "%02x", $0) }.joined())")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logger.error("Error writing characteristic value: \(error.localizedDescription)")
            return
        }
        
        logger.info("Value written to characteristic: \(characteristic.uuid)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logger.error("Error updating notification state: \(error.localizedDescription)")
            return
        }
        
        logger.info("Notification state updated for characteristic: \(characteristic.uuid)")
        logger.info("Is notifying: \(characteristic.isNotifying)")
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
    
//    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
//        isConnected = true
//        logger.info("Central subscribed to characteristic")
//    }
//    
//    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
//        isConnected = false
//        logger.info("Central unsubscribed from characteristic")
//    }
    
    
    // RUpdated peripheralManager delegate methods
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        // Generate new session ID when device connects
        let sessionId = UUID().uuidString
        let sessionInfo = SessionInfo(
            id: sessionId,
            timestamp: Date(),
            deviceName: central.identifier.uuidString,
            lastActivity: Date()
        )
        
        activeSessions[central] = sessionInfo
        connectedCentral = central
        currentSessionId = sessionId
        
        logger.info("""
        ======= New Session Established =======
        \(sessionInfo.debugDescription)
        =====================================
        """)
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.sessionStatus = "Active Session: \(sessionId)"
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        if let sessionInfo = activeSessions[central] {
            logger.info("""
            ======= Session Terminated =======
            \(sessionInfo.debugDescription)
            ================================
            """)
            
            activeSessions.removeValue(forKey: central)
            
            if central.identifier == connectedCentral?.identifier {
                currentSessionId = nil
                connectedCentral = nil
            }
        }
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.sessionStatus = "No Active Session"
        }
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




