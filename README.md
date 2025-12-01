# Rbnpuy

A Ruby library for controlling and monitoring input devices, inspired by Python's pynput.

This library allows you to control and monitor input devices. Currently, mouse and keyboard input and monitoring are supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rbnpuy'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rbnpuy

## Usage

### Controlling the Mouse

```ruby
require 'rbnpuy'

# Create a mouse controller
mouse = Rbnpuy::Mouse::Controller.new

# Move the mouse to absolute position
mouse.position = [100, 200]

# Get current position
x, y = mouse.position

# Move relative to current position
mouse.move(10, -10)

# Click
mouse.click(Rbnpuy::Mouse::Button::LEFT, 1)

# Press and release
mouse.press(Rbnpuy::Mouse::Button::LEFT)
mouse.release(Rbnpuy::Mouse::Button::LEFT)

# Scroll
mouse.scroll(0, 2)  # Scroll down 2 units
```

### Monitoring the Mouse

```ruby
require 'rbnpuy'

# Define callbacks
on_move = ->(x, y) { puts "Mouse moved to (#{x}, #{y})" }
on_click = ->(x, y, button, pressed) do
  action = pressed ? 'Pressed' : 'Released'
  puts "#{action} #{button} at (#{x}, #{y})"
end
on_scroll = ->(x, y, dx, dy) { puts "Scrolled (#{dx}, #{dy}) at (#{x}, #{y})" }

# Create and start listener
listener = Rbnpuy::Mouse::Listener.new(
  on_move: on_move,
  on_click: on_click,
  on_scroll: on_scroll
)

listener.start
listener.join
```

### Controlling the Keyboard

```ruby
require 'rbnpuy'

# Create a keyboard controller
keyboard = Rbnpuy::Keyboard::Controller.new

# Press and release a key
keyboard.press('a')
keyboard.release('a')

# Type a string
keyboard.type("Hello, World!")

# Press special keys
keyboard.press(Rbnpuy::Keyboard::Key::CTRL)
keyboard.press('c')
keyboard.release('c')
keyboard.release(Rbnpuy::Keyboard::Key::CTRL)

# Use tap for quick press and release
keyboard.tap(Rbnpuy::Keyboard::Key::ENTER)
```

### Monitoring the Keyboard

```ruby
require 'rbnpuy'

# Define callbacks
on_press = ->(key) { puts "Key pressed: #{key}" }
on_release = ->(key) { puts "Key released: #{key}" }

# Create and start listener
listener = Rbnpuy::Keyboard::Listener.new(
  on_press: on_press,
  on_release: on_release
)

listener.start
listener.join

# Stop listener
listener.stop
```

### Global Hotkeys

```ruby
require 'rbnpuy'

# Define hotkeys
hotkeys = {
  '<ctrl>+<alt>+h' => -> { puts 'Hotkey activated!' },
  '<cmd>+<shift>+q' => -> { puts 'Quit hotkey!' }
}

# Create listener
listener = Rbnpuy::Keyboard::GlobalHotKeys.new(hotkeys)
listener.start
listener.join
```

## Platform Support

- **macOS**: Full support using Quartz and Cocoa frameworks
- **Linux**: Full support using X11 and evdev
- **Windows**: Full support using Win32 API

## License

This project is licensed under the GNU Lesser General Public License v3 (LGPLv3) - see the LICENSE file for details.

## Acknowledgments

This library is inspired by and based on the design of [pynput](https://github.com/moses-palmer/pynput) by Moses Palmér.
