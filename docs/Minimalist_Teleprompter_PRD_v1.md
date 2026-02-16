# Minimalist Teleprompter for macOS - PRD v1

## 1. Product Overview
### 1.1 Project Background
Technical content creators (like coders) often struggle with remembering scripts while recording tutorials. Traditional teleprompter apps often lack efficient control mechanisms (requiring mouse interaction) or obstruct the coding environment (interfering with clicks in VS Code).

### 1.2 Target Audience
- Technical creators/influencers (Tech Bloggers, Coding Tutors).
- Professional screen casters who need to keep eye contact with the camera while recording.

### 1.3 Core Value Proposition
A minimalist, non-intrusive floating teleprompter that stays on top of all windows (including full-screen apps) and is controlled entirely by global hotkeys, allowing the user to keep their hands on the keyboard.

---

## 2. User Stories
| ID | User Story | Acceptance Criteria |
|----|------------|---------------------|
| US1| As a creator, I want a floating "narrow bar" UI. | The prompter should be a horizontal bar, minimizing screen occlusion. |
| US2| As a creator, I want to control the prompter via global hotkeys. | `Space`: Play/Pause. `Cmd + +/-`: Adjust speed. `Cmd + Up/Down`: Manual scroll. Works even when the app is in background. |
| US3| As a creator, I want the window to be "click-through". | I can click the buttons or text in the IDE (e.g., VS Code) *through* the teleprompter window. |
| US4| As a creator, I want the prompter to persist across Spaces. | The window follows the user when switching between full-screen apps or virtual desktops. |
| US5| As a creator, I want focus highlighting. | The center line of the text should be highlighted or have higher contrast than surrounding text. |

---

## 3. Functional Requirements

### 3.1 Window Management
- **Floating Mode**: Always on top (`NSWindow.Level.floating` or higher).
- **Sticky Window**: Visible on all desktop Spaces (Collection Behavior: `.canJoinAllSpaces`).
- **Mouse Transparency**: Enable mouse-through capability (`ignoresMouseEvents = true` toggle).
- **Minimalist UI**: No title bar, no standard window controls (Close/Min/Max) while in "Prompting Mode".

### 3.2 Global Hotkeys (Priority: HIGH)
The app must listen for system-wide events using `NSEvent` or `ShortcutRecorder`.
- **Space**: Toggle Auto-scroll Play/Pause.
- **Command + Up/Down**: Scroll text manually (Up/Down).
- **Command + "=" (Plus)**: Increase scroll speed.
- **Command + "-" (Minus)**: Decrease scroll speed.

### 3.3 Visual Presentation
- **Shape**: Long horizontal bar, default positioned near the top-center (camera area).
- **Focus Line**: A central focus area where the text is at its brightest/largest.
- **Opacity**: Adjustable background transparency (0% to 100%).
- **Font**: Large, sans-serif font (Monospaced option for code snippets).

### 3.4 Content Interaction
- **Paste Mode**: Simple text area for pasting the script.
- **Auto-Scroll**: Smooth scrolling with adjustable pixels-per-second.

---

## 4. Non-Functional Requirements
- **Performance**: Extremely low CPU usage to avoid affecting screen recording quality or IDE performance.
- **Installation**: Minimalist installation (single .app file).
- **Privacy**: No internet connection required; all script data is stored locally.

---

## 5. System Constraints & Risks
- **macOS Permissions**: App will require "Accessibility" or "Input Monitoring" permissions for global hotkeys.
- **Click-through Limitation**: If the window is mouse-transparent, the user needs a way to "Exit" or "Move" it (e.g., a "Lock/Unlock" mode).

---

## 6. Future Enhancements (v2)
- Multi-monitor support.
- External controller support (Bluetooth foot pedals).
- Rich text support (Colors, Bold).
