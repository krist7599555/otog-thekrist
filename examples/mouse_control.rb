#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rbnput'

# Example: Controlling the mouse
puts "=== Mouse Control Example ==="

mouse = Rbnput::Mouse::Controller.new

# Get current position
x, y = mouse.position
puts "Current mouse position: (#{x}, #{y})"

# Move to a specific position
puts "Moving mouse to (100, 100)..."
mouse.position = [100, 100]
sleep 0.5

# Move relative to current position
puts "Moving mouse 50 pixels right and 50 pixels down..."
mouse.move(50, 50)
sleep 0.5

# Click
puts "Clicking left button..."
mouse.click(Rbnput::Mouse::Button::LEFT, 1)
sleep 0.5

# Scroll
puts "Scrolling down..."
mouse.scroll(0, -2)

puts "\nMouse control example completed!"
