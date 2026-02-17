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
        // Allow a small buffer for measurement lag
        let effectiveHeight = contentHeight > 0 ? contentHeight : 100000
        if scrollOffset >= effectiveHeight {
            return
        }
        
        isPlaying = true
        timer?.cancel()
        timer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                
                let nextOffset = self.scrollOffset + CGFloat(self.scrollSpeed)
                
                // Stop exactly at contentHeight
                if self.contentHeight > 0 && nextOffset >= self.contentHeight {
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
        // Limit the scroll offset so user can't scroll into "empty space"
        // We allow scrolling up to contentHeight (where last line is at focus)
        let maxLimit = contentHeight > 0 ? contentHeight : 100000
        scrollOffset = max(0, min(maxLimit, scrollOffset + delta))
    }
    
    func updateOffsetWithWheel(deltaY: CGFloat) {
        // Natural scrolling: deltaY is positive when swiping down
        // In our system, scrollOffset += delta advances text (moves text up).
        manualScroll(delta: -deltaY)
    }
}
