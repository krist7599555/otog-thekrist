# frozen_string_literal: true

# Rbnpuy - Ruby Input Library
# Copyright (C) 2025
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.

require_relative "rbnpuy/version"
require_relative "rbnpuy/util"
require_relative "rbnpuy/keyboard"
require_relative "rbnpuy/mouse"

# The main Rbnpuy module
#
# This module imports keyboard and mouse submodules for controlling
# and monitoring input devices.
module Rbnpuy
  class Error < StandardError; end

  # Creates a logger with a name suitable for a specific class
  #
  # @param klass [Class] The class for which to create a logger
  # @return [Logger] a logger instance
  def self.logger(klass)
    require 'logger'
    Logger.new($stdout).tap do |log|
      log.progname = "#{klass.name}"
      log.level = Logger::WARN
    end
  end
end
