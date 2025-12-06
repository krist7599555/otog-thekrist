#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rbnput'

# Example: Monitoring keyboard events
puts "=== Keyboard Listener Example ==="
puts "Press any keys. Press Ctrl+C to exit."
puts

# Create and start listener
listener = Rbnput::Listener.new
listener.on_press do |key|
  puts "\b ⬇️ up   : #{key}"
end
listener.on_release do |key|
  puts "\b ⬆️ down : #{key}"
end

begin
  listener.start # start thread
  listener.join # wait thread exit 
rescue Interrupt
  puts "\nStopping listener..."
  puts "Listener stopped."
end
