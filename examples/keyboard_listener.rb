#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rbnput'

# Example: Monitoring keyboard events
puts "=== Keyboard Listener Example ==="
puts "Press any keys. Press Ctrl+C to exit."
puts

def get_constant_name_by_value(value, mod = Rbnput::Keyboard::Key)
  name = mod.constants.find do |const_name|
    mod.const_get(const_name) == value
  end
  return "<#{name}>" if name
end




# Define callbacks
on_press = lambda do |key, injected|
  return if injected
  puts "Key pressed: #{key} #{get_constant_name_by_value(key)}"
end

on_release = lambda do |key, injected|
  return if injected
  
  puts "Key released: #{key} #{get_constant_name_by_value(key)}"
end

# Create and start listener
listener = Rbnput::Keyboard::Listener.new(
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
