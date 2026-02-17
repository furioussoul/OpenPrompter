import SwiftUI
import AppKit

struct PrompterView: View {
    @ObservedObject var manager: PrompterManager
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(manager.isLocked ? manager.opacity : max(0.4, manager.opacity - 0.2))
            
            // Watermark Logo
            Image("HamsterLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .opacity(0.1)
                .grayscale(1.0)
            
            if !manager.isLocked {
                Color.blue.opacity(0.1)
                    .ignoresSafeArea()
            }
            
            // Text Content
            GeometryReader { geo in
                let centerLine = geo.size.height / 2
                
                VStack(spacing: manager.fontSize * 0.6) {
                    // We split by double newlines or single newlines to handle paragraphs better
                    // But for teleprompter, often simple newline split is best
                    let paragraphs = manager.content.components(separatedBy: .newlines)
                    
                    ForEach(0..<paragraphs.count, id: \.self) { index in
                        let text = paragraphs[index].trimmingCharacters(in: .whitespaces)
                        if !text.isEmpty {
                            Text(text)
                                .font(.system(size: manager.fontSize, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil) // CRITICAL: Allow text to wrap to multiple lines
                                .fixedSize(horizontal: false, vertical: true) // CRITICAL: Allow vertical expansion
                                .frame(maxWidth: geo.size.width - 60)
                        } else {
                            // Render empty lines as spacers
                            Spacer()
                                .frame(height: manager.fontSize * 0.5)
                        }
                    }
                }
                .frame(width: geo.size.width)
                .background(
                    GeometryReader { textGeo in
                        Color.clear
                            .onAppear {
                                manager.contentHeight = textGeo.size.height
                            }
                            .onChange(of: textGeo.size.height) { oldHeight, newHeight in
                                manager.contentHeight = newHeight
                            }
                    }
                )
                // Offset calculation
                .offset(y: centerLine - manager.scrollOffset)
                // Use a very subtle animation for manual jumps to make them less jarring
                .animation(.easeInOut(duration: 0.1), value: manager.scrollOffset)
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
