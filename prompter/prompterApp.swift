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
                        // Optional: Ensure window can receive focus if not locked
                        if !isLocked {
                            window.makeKey()
                        }
                    }.store(in: &self.cancellables)
            }
        }
    }
    
    func setupGlobalShortcuts() {
        // Local Monitor (handles events when app is active)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // Consumed
            }
            return event
        }
        
        // Global Monitor (handles events when app is in background)
        // Note: Requires Accessibility Permissions
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            _ = self?.handleKeyEvent(event)
        }
    }
    
    func handleKeyEvent(_ event: NSEvent) -> Bool {
        guard let manager = manager else { return false }
        
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let isCmd = flags == .command
        
        // Command + L: Toggle Lock
        if isCmd && event.charactersIgnoringModifiers == "l" {
            manager.isLocked.toggle()
            return true
        }
        
        // Command + E: Open Editor
        if isCmd && event.charactersIgnoringModifiers == "e" {
            openWindowAction?(id: "editor")
            return true
        }
        
        // Space: Play/Pause (keyCode 49)
        // We only handle Space globally if it's not being typed in a text field
        // But for global monitor, we usually want it. 
        // Note: Global Space might be annoying, but prompter users often want it.
        if event.keyCode == 49 && flags.isEmpty { 
            manager.togglePlayPause()
            return true
        }
        
        // Command + Plus/Minus: Speed
        if isCmd && (event.characters == "+" || event.characters == "=") {
            manager.updateSpeed(delta: 0.5)
            return true
        }
        if isCmd && event.characters == "-" {
            manager.updateSpeed(delta: -0.5)
            return true
        }
        
        // Command + Up/Down: Manual Scroll
        // KeyCodes: 126 = Up, 125 = Down
        if isCmd && event.keyCode == 126 { // Up Arrow
            // Rewind (Move text down)
            manager.manualScroll(delta: -20)
            return true
        }
        if isCmd && event.keyCode == 125 { // Down Arrow
            // Advance (Move text up)
            manager.manualScroll(delta: 20)
            return true
        }
        
        // Command + R: Reset
        if isCmd && event.charactersIgnoringModifiers == "r" {
            manager.resetScroll()
            return true
        }
        
        return false
    }
}
