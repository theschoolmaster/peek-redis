require 'redis'
require 'atomic'

# Instrument Redis time
class Redis::Client
  class << self
    attr_accessor :query_time, :read_query_count, :write_query_count, :keys
  end
  self.read_query_count = Atomic.new(0)
  self.write_query_count = Atomic.new(0)
  self.keys = []
  self.query_time = Atomic.new(0)

  def call_with_timing(*args, &block)
    start = Time.now
    call_without_timing(*args, &block)
  ensure
    duration = (Time.now - start)
    command = args.first[0]
    key = args.first[1]

    # handle namespaced keys
    unless Rails.cache.options[:namespace].nil?
      key.sub! "#{Rails.cache.options[:namespace]}:", ''
    end

    Redis::Client.query_time.update { |value| value + duration }

    Redis::Client.read_query_count.update { |value| value + 1 } if command == :get
    Redis::Client.write_query_count.update { |value| value + 1 } if command == :setex
    Redis::Client.keys << key
  end
  alias_method_chain :call, :timing
end

module Peek
  module Views
    class Redis < View
      def duration
        ::Redis::Client.query_time.value
      end

      def formatted_duration
        ms = duration * 1000
        if ms >= 1000
          "%.2fms" % ms
        else
          "%.0fms" % ms
        end
      end

      def reads
        ::Redis::Client.read_query_count.value
      end

      def writes
        ::Redis::Client.write_query_count.value
      end

      def keys
        ::Redis::Client.keys.uniq
      end

      def results
        {
          :duration => formatted_duration,
          :hits => reads - writes,
          :misses => writes,
          :keys => keys,
         }
      end

      private

      def setup_subscribers
        # Reset each counter when a new request starts
        subscribe 'start_processing.action_controller' do
          ::Redis::Client.query_time.value = 0
          ::Redis::Client.read_query_count.value = 0
          ::Redis::Client.write_query_count.value = 0
          ::Redis::Client.keys = []
        end
      end
    end
  end
end
