import SwiftUI
import AppKit

struct PrompterView: View {
    @ObservedObject var manager: PrompterManager
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(manager.isLocked ? manager.opacity : max(0.4, manager.opacity - 0.2))
            
            if !manager.isLocked {
                Color.blue.opacity(0.1)
                    .ignoresSafeArea()
            }
            
            // Text Content
            GeometryReader { geo in
                let centerLine = geo.size.height / 2
                
                // Splitting into lines helps with layout and prevents truncation of huge strings
                let lines = manager.content.components(separatedBy: .newlines)
                
                VStack(spacing: manager.fontSize * 0.3) {
                    ForEach(0..<lines.count, id: \.self) { index in
                        Text(lines[index])
                            .font(.system(size: manager.fontSize, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: geo.size.width - 40) // Prevent horizontal overflow
                    }
                }
                .frame(width: geo.size.width)
                .background(
                    GeometryReader { textGeo in
                        Color.clear
                            .onAppear {
                                manager.contentHeight = textGeo.size.height
                            }
                            .onChange(of: textGeo.size.height) { newHeight in
                                manager.contentHeight = newHeight
                            }
                    }
                )
                .offset(y: centerLine - manager.scrollOffset)
                .animation(.linear(duration: 0.1), value: manager.scrollOffset) // Smooth out manual jumps
            }
            .clipped()
            
            // Scroll Wheel Handler
            if !manager.isLocked {
                ScrollWheelHandler { deltaY in
                    manager.updateOffsetWithWheel(deltaY: deltaY)
                }
            }
            
            // Focus Highlight Area
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
            
            // Indicators
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

            // Gradient Overlays
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
                    .stroke(Color.white.opacity(0.8), lineWidth: 3)
                    .ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
    }
}

struct ScrollWheelHandler: NSViewRepresentable {
    var onScroll: (CGFloat) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = ScrollView()
        view.onScroll = onScroll
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? ScrollView)?.onScroll = onScroll
    }

    class ScrollView: NSView {
        var onScroll: ((CGFloat) -> Void)?

        override func scrollWheel(with event: NSEvent) {
            let delta = event.hasPreciseScrollingDeltas ? event.scrollingDeltaY : event.deltaY * 10
            onScroll?(delta)
        }
    }
}
