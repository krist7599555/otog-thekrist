# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-12-02

### Added
- Initial release of Rbnput
- Mouse control functionality
  - Move cursor to absolute position
  - Move cursor relative to current position
  - Click buttons (left, right, middle)
  - Scroll wheel control
- Mouse monitoring functionality
  - Listen for mouse movements
  - Listen for mouse clicks
  - Listen for scroll events
- Keyboard control functionality
  - Press and release individual keys
  - Type strings
  - Support for special keys (modifiers, function keys, etc.)
- Keyboard monitoring functionality
  - Listen for key presses
  - Listen for key releases
- Global hotkey support
  - Register multiple hotkey combinations
  - Parse hotkey strings (e.g., '<ctrl>+<alt>+h')
- Platform support
  - macOS implementation using CoreGraphics/Quartz
  - Placeholder implementations for Linux (X11) and Windows (Win32)
- Comprehensive documentation and examples

### Known Limitations
- macOS listener implementations require additional work for event taps
- Linux and Windows implementations are placeholders
- Media key support is limited on some platforms
