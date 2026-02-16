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
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Prompter" }) {
                window.level = .mainMenu + 1
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.backgroundColor = .clear
                window.isOpaque = false
                window.hasShadow = false
                window.isMovableByWindowBackground = true
                
                manager.$isLocked
                    .receive(on: RunLoop.main)
                    .sink { isLocked in
                        window.ignoresMouseEvents = isLocked
                    }.store(in: &self.cancellables)
            }
        }
    }
    
    func setupGlobalShortcuts() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return (self?.handleKeyEvent(event) ?? false) ? nil : event
        }
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            _ = self?.handleKeyEvent(event)
        }
    }
    
    func handleKeyEvent(_ event: NSEvent) -> Bool {
        guard let manager = manager else { return false }
        
        // Command + L: Toggle Lock
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "l" {
            manager.isLocked.toggle()
            return true
        }
        
        // Space: Play/Pause
        if event.keyCode == 49 { // Space
            manager.togglePlayPause()
            return true
        }
        
        // Command + Plus/Minus: Speed
        if event.modifierFlags.contains(.command) && (event.characters == "+" || event.characters == "=") {
            manager.updateSpeed(delta: 0.5)
            return true
        }
        if event.modifierFlags.contains(.command) && event.characters == "-" {
            manager.updateSpeed(delta: -0.5)
            return true
        }
        
        // Refined Navigation Logic (PRD 4.1)
        // Cmd + Up Arrow: Advance script (increase offset)
        if event.modifierFlags.contains(.command) && event.keyCode == 126 { // Up Arrow
            manager.manualScroll(delta: 20)
            return true
        }
        // Cmd + Down Arrow: Rewind script (decrease offset)
        if event.modifierFlags.contains(.command) && event.keyCode == 125 { // Down Arrow
            manager.manualScroll(delta: -20)
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
