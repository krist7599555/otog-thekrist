#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rbnput'

# Example: Monitoring mouse events
puts "=== Mouse Listener Example ==="
puts "Move your mouse, click, or scroll. Press Ctrl+C to exit."
puts

# Define callbacks
on_move = lambda do |x, y, injected|
  puts "Mouse moved to (#{x}, #{y})" unless injected
end

on_click = lambda do |x, y, button, pressed, injected|
  return if injected
  
  action = pressed ? 'Pressed' : 'Released'
  puts "#{action} #{button} at (#{x}, #{y})"
end

on_scroll = lambda do |x, y, dx, dy, injected|
  return if injected
  
  puts "Scrolled (#{dx}, #{dy}) at (#{x}, #{y})"
end

# Create and start listener
listener = Rbnput::Mouse::Listener.new(
  on_move: on_move,
  on_click: on_click,
  on_scroll: on_scroll
)

begin
  listener.start
  listener.join
rescue Interrupt
  puts "\nStopping listener..."
  listener.stop
  puts "Listener stopped."
end
