#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rbnput'

puts "=== Rbnput Quick Test ==="
puts "Platform: #{RUBY_PLATFORM}"
puts "Ruby version: #{RUBY_VERSION}"
puts

# Test mouse controller
puts "Testing Mouse Controller..."
begin
  mouse = Rbnput::Mouse::Controller.new
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
  keyboard = Rbnput::Keyboard::Controller.new
  puts "  ✓ Keyboard controller created: #{keyboard.class.name}"
  puts "  ✓ Available keys: #{Rbnput::Keyboard::Key.constants.size} constants"
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
puts "  ENTER: #{Rbnput::Keyboard::Key::ENTER.inspect}"
puts "  CTRL: #{Rbnput::Keyboard::Key::CTRL.inspect}"
puts "  SHIFT: #{Rbnput::Keyboard::Key::SHIFT.inspect}"

puts
puts "=== Test Complete ==="
