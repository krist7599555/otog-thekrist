---
description: Clone the Python pynput library to a full Ruby implementation in the current folder
---
# Workflow to clone pynput to Ruby (rbnput)

1. **Copy Python source**
   ```bash
   cp -R ./pynput_src ./pynput
   ```
   This provides reference implementation.

2. **Map Python package structure to Ruby**
   - `pynput/__init__.py` → `lib/rbnput.rb`
   - `pynput/_util` → `lib/rbnput/util.rb`
   - `pynput/mouse` → `lib/rbnput/mouse/*`
   - `pynput/keyboard` → `lib/rbnput/keyboard/*`
   - `pynput/_util/darwin.py` → `lib/rbnput/darwin_util.rb` (already created)

3. **Generate Ruby skeletons**
   For each Python file, create a corresponding Ruby file with the same public API:
   - Classes: `Controller`, `Listener`, `Button`, `Key`, `KeyCode`, etc.
   - Methods: `move`, `position=`, `click`, `press`, `release`, `type`, `on_move`, `on_click`, etc.
   Use the existing macOS implementations as a template.

4. **Implement platform‑specific backends**
   - **macOS (Darwin)**: Already implemented using `DarwinFFI` and CoreGraphics.
   - **Linux (Xorg)**: Use `ffi` to bind to X11 (`libX11.so`) for mouse/keyboard events. Create `lib/rbnput/mouse/xorg.rb` and `lib/rbnput/keyboard/xorg.rb`.
   - **Windows (Win32)**: Use `ffi` to bind to `user32.dll` and `kernel32.dll`. Implement `lib/rbnput/mouse/win32.rb` and `lib/rbnput/keyboard/win32.rb`.
   - For now, stub these files with `require_relative '../dummy'` and a warning, then replace with real FFI calls later.

5. **Add event handling**
   - Implement `ListenerMixin` (already done) for each platform.
   - Ensure `on_move`, `on_click`, `on_scroll`, `on_press`, `on_release` callbacks are invoked.

6. **Update documentation**
   - Extend `README.md` with usage examples for each platform.
   - Add a section on required accessibility permissions on macOS.

7. **Write tests**
   - Add RSpec tests under `spec/` covering controller creation, basic actions, and listener callbacks (mocking FFI where needed).
   - Ensure the test suite runs on macOS CI.

8. **Package the gem**
   - Verify `rbnput.gemspec` includes all files.
   - Run `gem build rbnput.gemspec` and `gem install ./rbnput-0.1.0.gem`.

9. **Continuous Integration**
   - Create a GitHub Actions workflow (`.github/workflows/ci.yml`) to run tests on macOS, Linux, and Windows.

10. **Future work**
    - Implement full Linux and Windows backends.
    - Add support for media keys and advanced hotkeys.
    - Publish the gem to RubyGems.

**Notes**:
- All FFI calls must handle errors gracefully and release resources.
- Keep the Ruby API compatible with the original Python `pynput` API to make migration easy.

**Run this workflow**:
```bash
# After copying the Python source
bundle install
ruby scripts/generate_ruby_skeletons.rb   # (you will need to create this helper script)
# Then manually fill in platform implementations.
```
