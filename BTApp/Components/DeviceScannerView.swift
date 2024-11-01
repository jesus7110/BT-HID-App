//
//  DeviceScannerView.swift
//  HIDapp
//
//  Created by Jesus Macbook on 25/10/24.
//

import SwiftUI
import CoreBluetooth

struct DeviceScannerView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if bluetoothService.isScanning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    Text("Scanning for devices...")
                }
                
                List(bluetoothService.discoveredDevices, id: \.identifier) { device in
                    Button(action: {
                        bluetoothService.connectToDevice(device)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(device.name ?? "Unknown Device")
                                    .font(.headline)
                                Text(device.identifier.uuidString)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Available Devices")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(bluetoothService.isScanning ? "Stop" : "Scan") {
                    if bluetoothService.isScanning {
                        bluetoothService.stopScanning()
                    } else {
                        bluetoothService.startScanning()
                    }
                }
            )
        }
    }
}
