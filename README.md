# OpenPrompter

OpenPrompter is a lightweight, efficient macOS teleprompter application designed for content creators, keynote speakers, and video producers. It provides a non-intrusive way to read scripts while maintaining eye contact with the camera.

## 🚀 Key Features

- **Global Shortcuts**: Control your script playback and navigation even when OpenPrompter is in the background.
- **Click-Through Mode (Lock)**: Lock the prompter window to make it non-interactive and "click-through," allowing you to place it over your presentation or camera preview without interference.
- **Natural Navigation**: Supports trackpad and mouse wheel scrolling for manual navigation when unlocked.
- **Smart Boundaries**: Automatically stops at the end of the script and prevents over-scrolling.
- **Visual Focus Line**: A subtle highlight and markers to help you keep track of your reading position.
- **Customizable**: Adjust font size, scroll speed, and window opacity to suit your environment.
- **Persistence**: Automatically saves your script and settings.

## ⌨️ Shortcut Guide

| Action | Shortcut |
|--------|----------|
| **Toggle Lock (Click-through)** | `Cmd + L` |
| **Play / Pause** | `Space` |
| **Open Script Editor** | `Cmd + E` |
| **Advance Text (Forward)** | `Cmd + Up Arrow` |
| **Rewind Text (Backward)** | `Cmd + Down Arrow` |
| **Increase Speed** | `Cmd + Plus (+)` |
| **Decrease Speed** | `Cmd + Minus (-)` |
| **Reset Scroll Position** | `Cmd + R` |

## 🛠 Installation & Usage

1. **Launch**: Open the application. The **Script Editor** will appear.
2. **Edit**: Type or paste your script into the editor.
3. **Open Prompter**: Click "Open Prompter Window" to show the overlay.
4. **Position**: Move and resize the prompter window to your preferred location (e.g., near the camera).
5. **Lock**: Press `Cmd + L` to lock the window into click-through mode.
6. **Start**: Press `Space` to start scrolling.

> **Note**: Accessibility permissions are required for global hotkeys to function when the application is not the active window.

## 💻 Tech Stack

- **Language**: Swift 5+
- **Framework**: SwiftUI / AppKit
- **Platform**: macOS 13.0+

---
Developed with ❤️ for content creators.
