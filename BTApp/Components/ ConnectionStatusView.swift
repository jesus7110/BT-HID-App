//
//   ConnectionStatusView.swift
//  HIDController
//
//  Created by Jesus Macbook on 18/10/24.
//

import SwiftUI

struct ConnectionStatusView: View {
    // MARK: - Properties
    let isConnected: Bool
    let isAdvertising: Bool
    let onToggle: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack {
            // Status Indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                
                Text(isConnected ? "Connected" : "Disconnected")
                    .font(.subheadline)
                    .foregroundColor(isConnected ? .green : .red)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isConnected ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            )
            
            Spacer()
            
            // Connect/Disconnect Button
            Button(action: onToggle) {
                Text(isAdvertising ? "Stop" : "Start")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isAdvertising ? Color.red : Color.blue)
                    )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Views
    private func statusIndicator(_ text: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.subheadline)
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview Provider
struct ConnectionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Connected State
            ConnectionStatusView(
                isConnected: true,
                isAdvertising: true,
                onToggle: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.light)
            
            // Disconnected State
            ConnectionStatusView(
                isConnected: false,
                isAdvertising: false,
                onToggle: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
        }
    }
}
