// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothService = BluetoothService()
    @State private var showPermissionAlert = false
    @State private var keyboardText: String = ""
    
    var body: some View {
        VStack {
            // Connection Status with correct SF Symbol names
            HStack {
                Image(systemName: bluetoothService.isConnected ? "dot.radiowaves.left.and.right" : "dot.radiowaves.left.and.right.slash")
                    .foregroundColor(bluetoothService.isConnected ? .blue : .gray)
                Text(bluetoothService.isConnected ? "Connected" : "Disconnected")
                    .foregroundColor(bluetoothService.isConnected ? .blue : .gray)
            }
            .padding()
            
            if bluetoothService.isConnected {
                // Trackpad View
                TrackpadView(
                    isConnected: bluetoothService.isConnected,
                    onMove: { previousLocation, currentLocation in
                        let deltaX = currentLocation.x - previousLocation.x
                        let deltaY = currentLocation.y - previousLocation.y
                        
                        bluetoothService.sendMouseMovement(
                            deltaX: Int8(max(-127, min(127, deltaX))),
                            deltaY: Int8(max(-127, min(127, deltaY)))
                        )
                    },
                    onClick: {
                        bluetoothService.sendMouseClick()
                    }
                )
                
                // Keyboard View
                KeyboardView(
                    text: $keyboardText,
                    isConnected: bluetoothService.isConnected,
                    onKeyPress: { keyCode, pressed in
                        bluetoothService.sendKeyPress(keyCode: keyCode, pressed: pressed)
                    }
                )
                
                // Disconnect Button
                Button(action: {
                    bluetoothService.disconnect()
                }) {
                    HStack {
                        Image(systemName: "link.badge.minus")
                        Text("Disconnect")
                    }
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                // Connect Button
                Button(action: {
                    if bluetoothService.permissionGranted {
                        bluetoothService.startScanning()
                    } else {
                        showPermissionAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "link.badge.plus")
                        Text("Connect to Mac")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            // Device List (when scanning)
            if bluetoothService.isScanning {
                VStack {
                    Text("Scanning for devices...")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ProgressView()
                        .padding()
                    
                    ForEach(bluetoothService.discoveredDevices, id: \.identifier) { device in
                        Button(action: {
                            bluetoothService.connectToDevice(device)
                        }) {
                            HStack {
                                Image(systemName: "laptopcomputer")
                                Text(device.name ?? "Unknown Device")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .alert("Bluetooth Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable Bluetooth permission in Settings to use this app.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
