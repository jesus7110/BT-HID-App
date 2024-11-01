// KeyboardView.swift
import SwiftUI

struct KeyboardView: View {
    @Binding var text: String
    let isConnected: Bool
    let onKeyPress: (UInt8, Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keyboard")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("Type here...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .disabled(!isConnected)
                .opacity(isConnected ? 1.0 : 0.6)
                .onChange(of: text) { newValue in
                    if let lastChar = newValue.last {
                        let keyCode = UInt8(lastChar.asciiValue ?? 0)
                        onKeyPress(keyCode, true)
                        
                        // Release key after short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onKeyPress(keyCode, false)
                        }
                    }
                }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView(
            text: .constant(""),
            isConnected: true,
            onKeyPress: { _, _ in }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
