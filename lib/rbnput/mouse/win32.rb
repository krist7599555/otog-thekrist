# frozen_string_literal: true

# Placeholder for Windows Win32 implementation
module Rbnput
  module Mouse
    module Win32
      # TODO: Implement using Win32 API
      # For now, use dummy implementation
      require_relative 'dummy'
      
      Button = Dummy::Button
      Controller = Dummy::Controller
      Listener = Dummy::Listener
    end
  end
end
