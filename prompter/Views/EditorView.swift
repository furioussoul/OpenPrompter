import SwiftUI
import ApplicationServices

struct EditorView: View {
    @ObservedObject var manager: PrompterManager
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image("HamsterLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                
                Text("OpenPrompter Editor")
                    .font(.title2.bold())
                Spacer()
                Button("Open Prompter Window") {
                    openWindow(id: "prompter")
                }
                .buttonStyle(.borderedProminent)
            }
            
            TextEditor(text: $manager.content)
                .font(.system(size: 16, design: .monospaced))
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .frame(minHeight: 300)
            
            Divider()
            
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                GridRow {
                    Text("Font Size")
                    Slider(value: $manager.fontSize, in: 20...120)
                    Text("\(Int(manager.fontSize))pt")
                }
                
                GridRow {
                    Text("Speed")
                    Slider(value: $manager.scrollSpeed, in: 0.1...10)
                    Text(String(format: "%.1f", manager.scrollSpeed))
                }
                
                GridRow {
                    Text("Opacity")
                    Slider(value: $manager.opacity, in: 0.1...1)
                    Text("\(Int(manager.opacity * 100))%")
                }
                
                GridRow {
                    Text("Mirror Mode")
                    Toggle("", isOn: $manager.isMirrored)
                        .toggleStyle(.switch)
                    Text(manager.isMirrored ? "On" : "Off")
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Shortcuts Reference:")
                    .font(.headline)
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("• Space: Play/Pause")
                        Text("• Cmd + R: Reset")
                        Text("• Cmd + L: Toggle Lock (Global)")
                        Text("• Cmd + I: Toggle Mirror (Global)")
                    }
                    VStack(alignment: .leading) {
                        Text("• Cmd + +/-: Change Speed")
                        Text("• Cmd + ↑/↓: Scroll Manual")
                        Text("• Cmd + E: Open Editor (Global)")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
            
            Divider()
            
            HStack(spacing: 15) {
                Button(action: manager.togglePlayPause) {
                    Label(manager.isPlaying ? "Pause" : "Play", systemImage: manager.isPlaying ? "pause.fill" : "play.fill")
                }
                .keyboardShortcut(.space, modifiers: [])
                
                Button(action: manager.resetScroll) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Spacer()
                
                Button(action: { manager.isLocked.toggle() }) {
                    Label(manager.isLocked ? "Unlock Mouse" : "Lock Mouse", 
                          systemImage: manager.isLocked ? "lock.fill" : "lock.open.fill")
                }
                .keyboardShortcut("l", modifiers: .command)
                .help("Cmd+L to toggle globally")
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .foregroundColor(.red)
            }
            
            // Accessibility Check
            HStack {
                Circle()
                    .fill(AXIsProcessTrusted() ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(AXIsProcessTrusted() ? "Global Hotkeys Active" : "Accessibility Permission Required for Global Hotkeys")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !AXIsProcessTrusted() {
                    Button("Grant") {
                        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
                        AXIsProcessTrustedWithOptions(options as CFDictionary)
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
            }
            .padding(.top, 5)
        }
        .padding()
        .frame(minWidth: 500, minHeight: 600)
    }
}
