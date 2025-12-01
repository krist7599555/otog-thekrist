#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rbnpuy'

puts "=== Rbnpuy Quick Test ==="
puts "Platform: #{RUBY_PLATFORM}"
puts "Ruby version: #{RUBY_VERSION}"
puts

# Test mouse controller
puts "Testing Mouse Controller..."
begin
  mouse = Rbnpuy::Mouse::Controller.new
  pos = mouse.position
  puts "  ✓ Mouse controller created"
  puts "  ✓ Current position: #{pos.inspect}"
rescue => e
  puts "  ✗ Error: #{e.message}"
end

puts

# Test keyboard controller
puts "Testing Keyboard Controller..."
begin
  keyboard = Rbnpuy::Keyboard::Controller.new
  puts "  ✓ Keyboard controller created: #{keyboard.class.name}"
  puts "  ✓ Available keys: #{Rbnpuy::Keyboard::Key.constants.size} constants"
rescue => e
  puts "  ✗ Error: #{e.message}"
end

puts

# Test button constants
puts "Testing Button Constants..."
buttons = [:unknown, :left, :middle, :right, :x1, :x2]
puts "  Mouse buttons: #{buttons.inspect}"

puts

# Test key constants (sample)
puts "Testing Key Constants (sample)..."
puts "  ENTER: #{Rbnpuy::Keyboard::Key::ENTER.inspect}"
puts "  CTRL: #{Rbnpuy::Keyboard::Key::CTRL.inspect}"
puts "  SHIFT: #{Rbnpuy::Keyboard::Key::SHIFT.inspect}"

puts
puts "=== Test Complete ==="
