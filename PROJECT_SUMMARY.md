# Rbnpuy - Ruby Input Library

## Project Summary

This is a Ruby clone of the Python `pynput` library, created to provide mouse and keyboard control and monitoring capabilities in Ruby.

## Project Structure

```
rbnpuy/
├── lib/
│   └── rbnpuy/
│       ├── version.rb              # Version information
│       ├── util.rb                 # Utility classes (AbstractListener, Events)
│       ├── mouse.rb                # Mouse module entry point
│       ├── mouse/
│       │   ├── base.rb             # Base mouse classes
│       │   ├── darwin.rb           # macOS implementation
│       │   ├── xorg.rb             # Linux placeholder
│       │   ├── win32.rb            # Windows placeholder
│       │   └── dummy.rb            # Fallback implementation
│       ├── keyboard.rb             # Keyboard module entry point
│       └── keyboard/
│           ├── base.rb             # Base keyboard classes
│           ├── darwin.rb           # macOS implementation
│           ├── xorg.rb             # Linux placeholder
│           ├── win32.rb            # Windows placeholder
│           └── dummy.rb            # Fallback implementation
├── examples/
│   ├── mouse_control.rb            # Mouse control example
│   ├── mouse_listener.rb           # Mouse monitoring example
│   ├── keyboard_control.rb         # Keyboard control example
│   ├── keyboard_listener.rb        # Keyboard monitoring example
│   └── global_hotkeys.rb           # Global hotkeys example
├── test/
│   └── quick_test.rb               # Basic functionality test
├── README.md                       # Comprehensive documentation
├── CHANGELOG.md                    # Version history
├── LICENSE                         # LGPL-3.0 license
├── Gemfile                         # Gem dependencies
├── rbnpuy.gemspec                  # Gem specification
└── .gitignore                      # Git ignore rules
```

## Features Implemented

### Mouse Control
- ✅ Move cursor to absolute position
- ✅ Move cursor relative to current position
- ✅ Get current cursor position
- ✅ Click buttons (left, right, middle)
- ✅ Press and release buttons
- ✅ Scroll wheel control
- ✅ Mouse event listening (implemented for macOS using CGEventTap)

### Keyboard Control
- ✅ Press and release individual keys
- ✅ Type strings
- ✅ Support for special keys (modifiers, function keys, etc.)
- ✅ Support for key combinations with modifiers
- ✅ Global hotkey registration and parsing
- ✅ Keyboard event listening (implemented for macOS using CGEventTap)

### Platform Support
- ✅ macOS (Darwin) - Full support including event listeners (requires accessibility permissions)
- 🔄 Linux (X11) - Placeholder (uses dummy implementation)
- 🔄 Windows (Win32) - Placeholder (uses dummy implementation)

## Architecture

The library follows the same architecture as pynput:

1. **Base Classes**: Define the interface and common functionality
2. **Platform-Specific Implementations**: Extend base classes with platform-specific code
3. **Backend Detection**: Automatically loads the appropriate implementation based on `RUBY_PLATFORM`
4. **Events System**: Provides synchronous iteration over input events
5. **Listeners**: Background threads that monitor input devices

## Key Design Decisions

1. **FFI for Native Calls**: Uses Ruby FFI to interface with system APIs (CoreGraphics on macOS)
2. **Module-based Organization**: Similar to pynput's package structure
3. **Thread-based Listeners**: Uses Ruby threads for asynchronous event monitoring
4. **Namespace Handling**: Avoided Ruby keyword conflicts (e.g., `END` → `KEY_END`)

## Testing

Run the quick test to verify basic functionality:

```bash
bundle install
ruby test/quick_test.rb
```

## Known Limitations

1. **Accessibility Permissions**: On macOS, monitoring input devices (listeners) requires accessibility permissions to be granted to the Ruby process (Terminal or IDE). If not granted, listeners will fail to start or receive events, and a warning will be logged.

2. **Linux/Windows**: Only placeholder implementations exist. Full implementations would require:
   - Linux: X11 bindings (via FFI) and evdev support
   - Windows: Win32 API bindings (via FFI)

3. **Media Keys**: Limited support for media keys on some platforms.

## Next Steps for Full Implementation

1. **macOS Event Tap**: Implement proper CGEventTap for mouse/keyboard listeners
2. **Linux Support**: Implement X11 and evdev bindings
3. **Windows Support**: Implement Win32 API bindings
4. **Tests**: Add comprehensive RSpec tests
5. **Documentation**: Generate YARD documentation
6. **CI/CD**: Set up GitHub Actions for testing across platforms

## Comparison with pynput

| Feature | pynput (Python) | rbnpuy (Ruby) |
|---------|----------------|---------------|
| Mouse Control | ✅ | ✅ |
| Mouse Monitoring | ✅ | ⚠️ (partial) |
| Keyboard Control | ✅ | ✅ |
| Keyboard Monitoring | ✅ | ⚠️ (partial) |
| Global Hotkeys | ✅ | ✅ |
| macOS Support | ✅ | ✅ (control only) |
| Linux Support | ✅ | 🔄 (placeholder) |
| Windows Support | ✅ | 🔄 (placeholder) |

## License

GNU Lesser General Public License v3 (LGPL-3.0)

## Acknowledgments

This library is inspired by and based on the design of [pynput](https://github.com/moses-palmer/pynput) by Moses Palmér.
