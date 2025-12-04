#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rbnput'

# Example: Controlling the keyboard
puts "=== Keyboard Control Example ==="

keyboard = Rbnput::Keyboard::Controller.new

# Type a simple string
puts "Typing 'Hello, World!'..."
keyboard.type("Hello, World!")
sleep 1

# Press and release individual keys
puts "Pressing Enter..."
keyboard.tap(Rbnput::Keyboard::Key::ENTER)
sleep 0.5

# Use modifiers
puts "Simulating Ctrl+C..."
keyboard.pressed(Rbnput::Keyboard::Key::CTRL) do
  keyboard.tap('c')
end
sleep 0.5

# Press special keys
puts "Pressing F1..."
keyboard.tap(Rbnput::Keyboard::Key::F1)

puts "\nKeyboard control example completed!"
puts "Note: Make sure you have a text editor or terminal focused to see the output."
