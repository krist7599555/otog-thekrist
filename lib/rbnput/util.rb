# frozen_string_literal: true

require 'thread'

module Rbnput
  module Util
    # Abstract base class for input device listeners
    class AbstractListener
      attr_reader :running, :daemon

      def initialize(suppress: false, **kwargs)
        @suppress = suppress
        @running = false
        @thread = nil
        @daemon = kwargs.fetch(:daemon, true)
        @condition = ConditionVariable.new
        @mutex = Mutex.new
        @log = Rbnput.logger(self.class)
      end

      # Start the listener in a separate thread
      def start
        @mutex.synchronize do
          return if @running
          
          @running = true
          @thread = Thread.new do
            begin
              _run
            rescue => e
              @log.error("Error in listener thread: #{e.message}")
              @log.error(e.backtrace.join("\n"))
            ensure
              @running = false
              @mutex.synchronize { @condition.broadcast }
            end
          end
          @thread.abort_on_exception = !@daemon
        end
        self
      end

      # Stop the listener
      def stop
        @mutex.synchronize do
          @running = false
          @condition.broadcast
        end
        @thread&.join(5) # Wait up to 5 seconds
        self
      end

      # Wait for the listener to complete
      def wait
        @mutex.synchronize do
          @condition.wait(@mutex) while @running
        end
      end

      # Join the listener thread
      def join
        @thread&.join
      end

      # Check if listener is alive
      def alive?
        @running && @thread&.alive?
      end

      protected

      # Platform-specific run implementation
      # Must be implemented by subclasses
      def _run
        raise NotImplementedError, "Subclasses must implement _run"
      end

      # Wrap a callback to handle nil and ensure proper arity
      def _wrap(callback, arity)
        return nil if callback.nil?
        
        lambda do |*args|
          begin
            callback.call(*args.take(arity))
          rescue => e
            @log.error("Error in callback: #{e.message}")
            @log.error(e.backtrace.join("\n"))
          end
        end
      end
    end

    # Base class for event-based listeners
    class Events
      class Event
        attr_reader :timestamp

        def initialize
          @timestamp = Time.now
        end
      end

      def initialize(**callbacks)
        @callbacks = callbacks
        @queue = Queue.new
        @listener = nil
      end

      # Get the next event from the queue
      def get(timeout: nil)
        if timeout
          Timeout.timeout(timeout) { @queue.pop }
        else
          @queue.pop
        end
      rescue Timeout::Error
        nil
      end

      # Start listening for events
      def start
        return if @listener

        listener_callbacks = @callbacks.transform_values do |event_class|
          lambda do |*args|
            @queue.push(event_class.new(*args))
          end
        end

        @listener = self.class::_Listener.new(**listener_callbacks)
        @listener.start
      end

      # Stop listening for events
      def stop
        @listener&.stop
        @listener = nil
      end

      # Iterate over events
      def each
        return enum_for(:each) unless block_given?

        start unless @listener
        loop do
          event = get
          yield event if event
        end
      end
    end
    
  end
end
