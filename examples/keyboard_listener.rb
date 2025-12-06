#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rbnput'

# Example: Monitoring keyboard events
puts "=== Keyboard Listener Example ==="
puts "Press any keys. Press Ctrl+C to exit."
puts

# Define callbacks
on_press = lambda do |key, injected|
  return if injected
  puts "Key pressed: #{key}"
end

on_release = lambda do |key, injected|
  return if injected
  
  puts "Key released: #{key}"
end

# Create and start listener
listener = Rbnput::Listener.new(
  on_press: on_press,
  on_release: on_release
)

begin
  listener.start
  listener.join
rescue Interrupt
  puts "\nStopping listener..."
  listener.sto
  puts "Listener stopped."
end
