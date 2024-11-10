//
//  PlatformSelectorView.swift
//  BTApp
//
//  Created by Jesus Macbook on 2/11/24.
//


import SwiftUI

struct PlatformSelectorView: View {
    @Binding var selectedPlatform: Platform
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Select Platform")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                PlatformButton(
                    platform: .macOS,
                    isSelected: selectedPlatform == .macOS,
                    action: { selectedPlatform = .macOS }
                )
                
                PlatformButton(
                    platform: .windows,
                    isSelected: selectedPlatform == .windows,
                    action: { selectedPlatform = .windows }
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

struct PlatformButton: View {
    let platform: Platform
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: platform == .macOS ? "apple.logo" : "window.vertical.closed")
                    .font(.system(size: 24))
                Text(platform.description)
                    .font(.subheadline)
            }
            .frame(width: 100, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .foregroundColor(isSelected ? .blue : .primary)
    }
}
