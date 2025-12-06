# frozen_string_literal: true

require 'thread'

class Rbnput::BaseThread

  protected
  # Platform-specific run implementation
  # Must be implemented by subclasses
  def _run; raise NotImplementedError, "Subclasses must implement _run" end

  public
  attr_reader :running
  def initialize
    @running = false
    @thread = nil
    @mutex = Mutex.new
  end

  # Start the listener in a separate thread
  def start
    @mutex.synchronize do
      return if @running
      @running = true
      @thread = Thread.new do
        begin; _run
        ensure; @running = false end
      end
    end
    self
  end

  # Stop the listener
  def stop
    @mutex.synchronize do; @running = false end
    @thread&.join(5) # Wait up to 5 seconds
    self
  end

  def join; @thread&.join end
  def alive?; @running && @thread&.alive? end


end
