# OpenPrompter UX Optimization - PRD v2

## 1. Document Information
- **Title**: OpenPrompter UX Optimization
- **Version**: v2
- **Status**: Draft
- **Date**: 2026-02-16
- **Author**: Requirements Analyst

## 2. Product Overview
Based on user feedback from the v1 prototype, this document outlines critical improvements for the OpenPrompter macOS application. The focus is on aligning control logic with user intuition, preventing content "loss" at the end of scripts, and enhancing manual navigation.

---

## 3. User Stories & Acceptance Criteria

| ID | User Story | Acceptance Criteria |
|----|------------|---------------------|
| US2.1 | As a speaker, I want "Down Arrow" to pull previous text back into view. | `Cmd + Down Arrow` decreases `scrollOffset` (text moves visually downward). `Cmd + Up Arrow` increases `scrollOffset` (text moves visually upward). |
| US2.2 | As a speaker, I want the prompter to stop at the end of the script. | Auto-scrolling stops once the last line of text reaches the focus area. User cannot scroll past the content boundaries. |
| US2.3 | As a speaker, I want to use my trackpad/mouse wheel to navigate. | In unlocked mode, the user can manually scroll the text using standard macOS gestures/wheels. |

---

## 4. Functional Requirements

### 4.1 Refined Navigation Logic
- **Shortcut Remapping**:
    - `Cmd + Up Arrow`: `scrollOffset += 20` (Advance script)
    - `Cmd + Down Arrow`: `scrollOffset -= 20` (Rewind script)
- **Manual Scroll Support**:
    - The `PrompterView` must capture scroll wheel events when the window is in "unlocked" mode.
    - Standard trackpad vertical swiping should update the `scrollOffset`.

### 4.2 Content Boundary Management
- **Height Calculation**: The system must dynamically calculate the total height of the rendered text.
- **Clamp Logic**: `scrollOffset` must be clamped within the range `[0, MaxHeight]`. 
- **Auto-stop**: If `isPlaying` is true and `scrollOffset` reaches `MaxHeight`, `isPlaying` should be set to `false`.

### 4.3 UI/UX Enhancements
- **Unlocked Feedback**: Visual indication (border/background tint) must clearly show when the window is "interactive" (to allow wheel scrolling) vs "click-through".

---

## 5. Non-Functional Requirements
- **Smoothness**: Manual scrolling via wheel/trackpad should be as smooth as native macOS applications.
- **Zero Overscroll**: There should be no "rubber-banding" or empty space visible beyond the script content boundaries.

---

## 6. Technical Implementation Details

### 6.1 PrompterManager Updates
- Add `contentHeight: CGFloat` published property.
- Update `manualScroll(delta:)` to include boundary checks.
- Add `updateOffsetWithWheel(deltaY:)` method.

### 6.2 PrompterView Updates
- Use `GeometryReader` or `TextEditor` content size tracking to update `manager.contentHeight`.
- Wrap the content in a way that captures scroll events (e.g., a custom `NSViewRepresentable` if SwiftUI's standard `ScrollView` interferes with the custom offset-based layout).

### 6.3 Shortcut Updates
- Modify `AppDelegate.handleKeyEvent` to match the new direction mapping.

---

## 7. Success Metrics
- User can successfully "pull back" to re-read a skipped sentence without confusion about key directions.
- No "black screen" or "empty screen" states when reaching the end of a script.
- Navigation feels natural using both keyboard and trackpad.
