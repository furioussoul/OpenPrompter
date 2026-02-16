import SwiftUI
import AppKit
import Combine

@main
struct prompterApp: App {
    @StateObject private var manager = PrompterManager()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        Window("Script Editor", id: "editor") {
            EditorView(manager: manager)
                .onAppear {
                    appDelegate.manager = manager
                    appDelegate.openWindowAction = openWindow
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Script Editor") {
                    openWindow(id: "editor")
                }
                .keyboardShortcut("e", modifiers: .command)
            }
            
            CommandGroup(after: .newItem) {
                Button("Toggle Play/Pause") {
                    manager.togglePlayPause()
                }
                .keyboardShortcut(.space, modifiers: [])
                
                Button("Reset Prompter") {
                    manager.resetScroll()
                }
                .keyboardShortcut("r", modifiers: .command)
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
    var openWindowAction: OpenWindowAction?
    var eventMonitor: Any?
    var localMonitor: Any?
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupGlobalShortcuts()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openWindowAction?(id: "editor")
        }
        return true
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
                        if !isLocked {
                            window.makeKey()
                        }
                    }.store(in: &self.cancellables)
            }
        }
    }
    
    func setupGlobalShortcuts() {
        // Local Monitor
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil
            }
            return event
        }
        
        // Global Monitor
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            _ = self?.handleKeyEvent(event)
        }
    }
    
    func handleKeyEvent(_ event: NSEvent) -> Bool {
        guard let manager = manager else { return false }
        
        let flags = event.modifierFlags
        let isCmd = flags.contains(.command)
        let isOption = flags.contains(.option)
        let isControl = flags.contains(.control)
        let isShift = flags.contains(.shift)
        
        // We want Cmd + Key, but ignoring things like CapsLock or NumLock
        let hasCmd = isCmd && !isOption && !isControl
        
        // Command + L: Toggle Lock
        if hasCmd && event.charactersIgnoringModifiers?.lowercased() == "l" {
            manager.isLocked.toggle()
            return true
        }
        
        // Command + E: Open Editor
        if hasCmd && event.charactersIgnoringModifiers?.lowercased() == "e" {
            openWindowAction?(id: "editor")
            return true
        }
        
        // Space: Play/Pause (keyCode 49)
        if event.keyCode == 49 { 
            // Allow space only if no major modifiers (Cmd/Opt/Ctrl) are pressed
            if !isCmd && !isOption && !isControl {
                manager.togglePlayPause()
                return true
            }
        }
        
        // Command + Plus/Minus: Speed
        if hasCmd && (event.charactersIgnoringModifiers == "+" || event.charactersIgnoringModifiers == "=") {
            manager.updateSpeed(delta: 0.5)
            return true
        }
        if hasCmd && event.charactersIgnoringModifiers == "-" {
            manager.updateSpeed(delta: -0.5)
            return true
        }
        
        // Command + Up/Down: Manual Scroll
        // 126 = Up, 125 = Down
        if isCmd && event.keyCode == 126 { // Up Arrow
            // User wants to see content ABOVE -> decrease scrollOffset
            manager.manualScroll(delta: -60)
            return true
        }
        if isCmd && event.keyCode == 125 { // Down Arrow
            // User wants to see content BELOW -> increase scrollOffset
            manager.manualScroll(delta: 60)
            return true
        }
        
        // Command + R: Reset
        if hasCmd && event.charactersIgnoringModifiers?.lowercased() == "r" {
            manager.resetScroll()
            return true
        }
        
        return false
    }
}
