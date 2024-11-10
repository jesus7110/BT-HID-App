//// KeyboardView.swift
import SwiftUI

struct KeyboardView: View {
    @Binding var text: String
    let isConnected: Bool
    let onKeyPress: (UInt8, Bool, Bool) -> Void
    
    @State private var previousText = ""
    @State private var activeModifiers: Set<UInt8> = []
    
    private let specialKeys: [[SpecialKey]] = [
        [
            SpecialKey(text: "CTRL", keyCode: KeyCodes.leftControl, isModifier: true),
            SpecialKey(text: "SHIFT", keyCode: KeyCodes.leftShift, isModifier: true),
            SpecialKey(text: "TAB", keyCode: KeyCodes.tab, isModifier: false)
        ],
        [
            SpecialKey(text: "OPT", keyCode: KeyCodes.leftAlt, isModifier: true),
            SpecialKey(text: "CMD", keyCode: KeyCodes.leftGUI, isModifier: true),
            SpecialKey(text: "FN", keyCode: KeyCodes.f1, isModifier: true),
            SpecialKey(text: "RETURN", keyCode: KeyCodes.enter, isModifier: false)
        ]
    ]
    
    struct SpecialKey: Identifiable {
        let id = UUID()
        let text: String
        let keyCode: UInt8
        let isModifier: Bool
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keyboard")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Special Function Keys
            VStack(spacing: 8) {
                ForEach(Array(specialKeys.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 8) {
                        ForEach(row) { key in
                            SpecialKeyButton(
                                text: key.text,
                                isActive: activeModifiers.contains(key.keyCode),
                                isEnabled: isConnected
                            ) {
                                handleSpecialKey(key)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 8)
            
            // Regular keyboard input
            TextField("Type here...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .disabled(!isConnected)
                .opacity(isConnected ? 1.0 : 0.6)
                .onChange(of: text) { oldValue, newValue in
                    handleTextChange(from: oldValue, to: newValue)
                }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
    
    private func handleSpecialKey(_ key: SpecialKey) {
        if key.isModifier {
            if activeModifiers.contains(key.keyCode) {
                activeModifiers.remove(key.keyCode)
                onKeyPress(key.keyCode, false, true)
            } else {
                activeModifiers.insert(key.keyCode)
                onKeyPress(key.keyCode, true, true)
            }
        } else {
            onKeyPress(key.keyCode, true, false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onKeyPress(key.keyCode, false, false)
            }
        }
    }
    
    private func handleTextChange(from oldValue: String, to newValue: String) {
        guard isConnected else { return }
        
        // Handle backspace
        if newValue.count < oldValue.count {
            onKeyPress(KeyCodes.backspace, true, false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onKeyPress(KeyCodes.backspace, false, false)
            }
            return
        }
        
        // Handle new character
        if let addedChar = newValue.last,
           let keyCode = KeyCodes.getKeyCode(for: addedChar) {
            onKeyPress(keyCode, true, false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onKeyPress(keyCode, false, false)
            }
        }
        
        // Clear the text field after processing
        DispatchQueue.main.async {
            self.text = ""
        }
    }
}

struct SpecialKeyButton: View {
    let text: String
    let isActive: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(buttonColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(strokeColor, lineWidth: 1)
                        )
                )
                .foregroundColor(textColor)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private var buttonColor: Color {
        if !isEnabled {
            return Color(.systemGray5)
        }
        return isActive ? Color(.systemGray4) : Color(.systemGray6)
    }
    
    private var strokeColor: Color {
        if !isEnabled {
            return Color(.systemGray4)
        }
        return isActive ? .blue : Color(.systemGray3)
    }
    
    private var textColor: Color {
        if !isEnabled {
            return Color(.systemGray)
        }
        return isActive ? .blue : .primary
    }
}
