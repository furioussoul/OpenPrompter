import SwiftUI

struct PrompterView: View {
    @ObservedObject var manager: PrompterManager
    
    var body: some View {
        ZStack {
            // Background with adjustable opacity
            Color.black.opacity(manager.isLocked ? manager.opacity : 0.7)
            
            // Text Content
            GeometryReader { geo in
                let centerLine = geo.size.height / 2
                
                VStack(spacing: 0) {
                    Text(manager.content)
                        .font(.system(size: manager.fontSize, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        // This offset calculation keeps the text moving through the center
                        .offset(y: centerLine - manager.scrollOffset)
                }
                .frame(width: geo.size.width)
            }
            .clipped()
            
            // Focus Highlight Area (The "Focus Line")
            // A subtle highlight bar that tracks the "current reading" position
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.15), .white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: manager.fontSize * 1.6)
                .overlay(
                    Rectangle().stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
                .allowsHitTesting(false)
            
            // Visual indicators for the focus line (Left/Right carets)
            HStack {
                Image(systemName: "chevron.right")
                    .foregroundColor(.yellow.opacity(0.8))
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                Image(systemName: "chevron.left")
                    .foregroundColor(.yellow.opacity(0.8))
                    .font(.system(size: 24, weight: .bold))
            }
            .padding(.horizontal, 8)
            .allowsHitTesting(false)

            // Gradient Overlays to fade out non-focused text
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [.black, .black.opacity(0)]),
                    startPoint: .top,
                    endPoint: .center
                )
                .frame(height: 150)
                
                Spacer()
                
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0), .black]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 150)
            }
            .allowsHitTesting(false)
            
            // Border when unlocked
            if !manager.isLocked {
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
            }
        }
        .ignoresSafeArea()
    }
}
