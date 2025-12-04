# frozen_string_literal: true

# Placeholder for Linux X11 implementation
module Rbnput
  module Mouse
    module Xorg
      # TODO: Implement using X11 bindings
      # For now, use dummy implementation
      require_relative 'dummy'
      
      Button = Dummy::Button
      Controller = Dummy::Controller
      Listener = Dummy::Listener
    end
  end
end
