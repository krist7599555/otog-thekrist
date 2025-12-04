# frozen_string_literal: true

# Placeholder for Linux X11 keyboard implementation
module Rbnpuy
  module Keyboard
    module Xorg
      # TODO: Implement using X11 bindings
      # For now, use dummy implementation
      require_relative 'dummy'
      
      KeyCode = Dummy::KeyCode
      Key = Dummy::Key
      Controller = Dummy::Controller
      Listener = Dummy::Listener
    end
  end
end
