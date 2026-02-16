import SwiftUI
import Combine

class PrompterManager: ObservableObject {
    // Persistence using UserDefaults
    @AppStorage("script_content") var content: String = Script.defaultScript.content
    @AppStorage("scroll_speed") var scrollSpeed: Double = 2.0
    @AppStorage("font_size") var fontSize: Double = 45
    @AppStorage("window_opacity") var opacity: Double = 0.8
    
    @Published var isPlaying: Bool = false
    @Published var scrollOffset: CGFloat = 0
    @Published var isLocked: Bool = false // Locked means click-through
    @Published var contentHeight: CGFloat = 0
    
    private var timer: AnyCancellable?
    
    func togglePlayPause() {
        if isPlaying {
            stopScrolling()
        } else {
            startScrolling()
        }
    }
    
    func startScrolling() {
        // If already at end, don't start
        if scrollOffset >= contentHeight {
            return
        }
        
        isPlaying = true
        timer?.cancel()
        timer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                
                let nextOffset = self.scrollOffset + CGFloat(self.scrollSpeed)
                if nextOffset >= self.contentHeight {
                    self.scrollOffset = self.contentHeight
                    self.stopScrolling()
                } else {
                    self.scrollOffset = nextOffset
                }
            }
    }
    
    func stopScrolling() {
        isPlaying = false
        timer?.cancel()
    }
    
    func resetScroll() {
        scrollOffset = 0
        stopScrolling()
    }
    
    func updateSpeed(delta: Double) {
        scrollSpeed = max(0.1, min(20.0, scrollSpeed + delta))
    }
    
    func manualScroll(delta: CGFloat) {
        scrollOffset = max(0, min(contentHeight, scrollOffset + delta))
    }
    
    func updateOffsetWithWheel(deltaY: CGFloat) {
        // Natural scrolling: deltaY is positive when swiping down (which should move text down/rewind)
        // In our system, scrollOffset += delta advances text (moves text up).
        // So we want to subtract deltaY to match natural macOS feel if deltaY is from standard events.
        // Actually, NSEvent.scrollingDeltaY is positive when scrolling "up" (fingers moving down on trackpad).
        // Let's test with simple subtraction first.
        manualScroll(delta: -deltaY)
    }
}
