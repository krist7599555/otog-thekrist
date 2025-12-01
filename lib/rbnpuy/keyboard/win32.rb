# frozen_string_literal: true

# Placeholder for Windows Win32 keyboard implementation
module Rbnpuy
  module Keyboard
    module Win32
      # TODO: Implement using Win32 API
      # For now, use dummy implementation
      require_relative 'dummy'
      
      KeyCode = Dummy::KeyCode
      Key = Dummy::Key
      Controller = Dummy::Controller
      Listener = Dummy::Listener
    end
  end
end
