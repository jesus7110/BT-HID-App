// TrackpadView.swift
import SwiftUI

struct TrackpadView: View {
    let isConnected: Bool
    let onMove: (CGPoint, CGPoint) -> Void
    let onClick: () -> Void
    
    @State private var previousLocation: CGPoint = .zero
    @State private var isDragging: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trackpad")
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 250)
                    .cornerRadius(12)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let location = value.location
                                if !isDragging {
                                    isDragging = true
                                    previousLocation = location
                                    return
                                }
                                
                                onMove(previousLocation, location)
                                previousLocation = location
                            }
                            .onEnded { _ in
                                isDragging = false
                                previousLocation = .zero
                            }
                    )
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                onClick()
                            }
                    )
                
                if !isConnected {
                    Text("Connect to use trackpad")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

struct TrackpadView_Previews: PreviewProvider {
    static var previews: some View {
        TrackpadView(
            isConnected: true,
            onMove: { _, _ in },
            onClick: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
