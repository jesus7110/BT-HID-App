//
//  ViewModifiers.swift
//  HIDController
//
//  Created by Jesus Macbook on 18/10/24.
//

import SwiftUI

// MARK: - Control Area Modifier
struct ControlAreaModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Trackpad Area Modifier
struct TrackpadAreaModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(.systemGray4), lineWidth: 1)
                    )
            )
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

// MARK: - Connection Button Modifier
struct ConnectionButtonModifier: ViewModifier {
    let isAdvertising: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isAdvertising ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Section Title Modifier
struct SectionTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
}

// MARK: - Connection Status Modifier
struct ConnectionStatusModifier: ViewModifier {
    let isConnected: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .foregroundColor(isConnected ? .green : .red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isConnected ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            )
    }
}

// MARK: - Keyboard Input Modifier
struct KeyboardInputModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

// MARK: - View Extensions
extension View {
    func controlArea() -> some View {
        modifier(ControlAreaModifier())
    }
    
    func trackpadArea(isEnabled: Bool) -> some View {
        modifier(TrackpadAreaModifier(isEnabled: isEnabled))
    }
    
    func connectionButton(isAdvertising: Bool) -> some View {
        modifier(ConnectionButtonModifier(isAdvertising: isAdvertising))
    }
    
    func sectionTitle() -> some View {
        modifier(SectionTitleModifier())
    }
    
    func connectionStatus(isConnected: Bool) -> some View {
        modifier(ConnectionStatusModifier(isConnected: isConnected))
    }
    
    func keyboardInput(isEnabled: Bool) -> some View {
        modifier(KeyboardInputModifier(isEnabled: isEnabled))
    }
}
