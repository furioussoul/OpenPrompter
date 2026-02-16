import SwiftUI
import AppKit
import Combine

@main
struct prompterApp: App {
    @StateObject private var manager = PrompterManager()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Window("Script Editor", id: "editor") {
            EditorView(manager: manager)
                .onAppear {
                    // Close the prompter window if it was open to ensure fresh state
                    // Or just ensure it's linked
                    appDelegate.manager = manager
                }
        }
        
        Window("Prompter", id: "prompter") {
            PrompterView(manager: manager)
                .onAppear {
                    appDelegate.setupPrompterWindow(manager: manager)
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var manager: PrompterManager?
    var eventMonitor: Any?
    var localMonitor: Any?
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupGlobalShortcuts()
    }
    
    func setupPrompterWindow(manager: PrompterManager) {
        self.manager = manager
        // Find the window created by SwiftUI and customize it
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Prompter" }) {
                window.level = .mainMenu + 1
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.backgroundColor = .clear
                window.isOpaque = false
                window.hasShadow = false
                window.isMovableByWindowBackground = true
                
                // Observe lock state
                manager.$isLocked
                    .receive(on: RunLoop.main)
                    .sink { isLocked in
                        window.ignoresMouseEvents = isLocked
                        if isLocked {
                            window.backgroundColor = .clear
                        } else {
                            window.backgroundColor = NSColor.black.withAlphaComponent(0.1)
                        }
                    }.store(in: &self.cancellables)
            }
        }
    }
    
    func setupGlobalShortcuts() {
        // Local Monitor (when app is active)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return (self?.handleKeyEvent(event) ?? false) ? nil : event
        }
        
        // Global Monitor (when app is background)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            _ = self?.handleKeyEvent(event)
        }
    }
    
    func handleKeyEvent(_ event: NSEvent) -> Bool {
        guard let manager = manager else { return false }
        
        // Command + L: Toggle Lock (Always handle this so user can unlock)
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "l" {
            manager.isLocked.toggle()
            return true
        }
        
        // Other shortcuts only if not typing in the editor (or handle globally)
        // Space: Play/Pause
        if event.keyCode == 49 { // Space
            manager.togglePlayPause()
            return true
        }
        
        // Command + Plus
        if event.modifierFlags.contains(.command) && (event.characters == "+" || event.characters == "=") {
            manager.updateSpeed(delta: 0.5)
            return true
        }
        
        // Command + Minus
        if event.modifierFlags.contains(.command) && event.characters == "-" {
            manager.updateSpeed(delta: -0.5)
            return true
        }
        
        // Command + Up/Down: Manual Scroll
        if event.modifierFlags.contains(.command) && event.keyCode == 126 { // Up Arrow
            manager.manualScroll(delta: -20)
            return true
        }
        if event.modifierFlags.contains(.command) && event.keyCode == 125 { // Down Arrow
            manager.manualScroll(delta: 20)
            return true
        }
        
        // Command + R: Reset
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "r" {
            manager.resetScroll()
            return true
        }
        
        return false
    }
}
