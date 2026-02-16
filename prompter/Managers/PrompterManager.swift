import SwiftUI
import Combine

class PrompterManager: ObservableObject {
    // Persistence using UserDefaults
    @AppStorage("script_content") var content: String = Script.defaultScript.content
    @AppStorage("scroll_speed") var scrollSpeed: Double = 2.0
    @AppStorage("font_size") var fontSize: CGFloat = 45
    @AppStorage("window_opacity") var opacity: Double = 0.8
    
    @Published var isPlaying: Bool = false
    @Published var scrollOffset: CGFloat = 0
    @Published var isLocked: Bool = false // Locked means click-through
    
    private var timer: AnyCancellable?
    
    func togglePlayPause() {
        if isPlaying {
            stopScrolling()
        } else {
            startScrolling()
        }
    }
    
    func startScrolling() {
        isPlaying = true
        timer?.cancel()
        timer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                self.scrollOffset += CGFloat(self.scrollSpeed)
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
        scrollOffset = max(0, scrollOffset + delta)
    }
}
