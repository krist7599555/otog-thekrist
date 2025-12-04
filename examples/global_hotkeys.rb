#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rbnput'

# Example: Global hotkeys
puts "=== Global Hotkeys Example ==="
puts "Press Ctrl+Alt+H to trigger hotkey 1"
puts "Press Cmd+Shift+Q to trigger hotkey 2"
puts "Press Ctrl+C to exit."
puts

# Define hotkeys
hotkeys = {
  '<ctrl>+<alt>+h' => lambda do
    puts "\n🔥 Hotkey 1 activated! (Ctrl+Alt+H)"
  end,
  '<cmd>+<shift>+q' => lambda do
    puts "\n🔥 Hotkey 2 activated! (Cmd+Shift+Q)"
  end
}

# Create listener
listener = Rbnput::Keyboard::GlobalHotKeys.new(hotkeys)

begin
  listener.start
  listener.join
rescue Interrupt
  puts "\nStopping hotkey listener..."
  listener.stop
  puts "Hotkey listener stopped."
end
