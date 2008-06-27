module MiniBot
  class Logger
    @levels = {}

    class << self
      def with_level(level, &block)
        @levels[level] = block
      end

      attr_reader :levels
    end

    attr_reader :level

    def write(str)
      time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
      @target.printf "<%s> [%s] %s\n",time, level, str
      @target.flush
    end

    def level=(level)
      @level = level.to_sym
      self.class.levels[@level].call(self)
    end

    private

    def initialize(file_name_or_io)
      @target = if String === file_name_or_io
        File.new(file_name_or_io, "w")
      else
        file_name_or_io
      end
    end

    def close
      @target.close
    end
  end
end

module Kernel
  attr_accessor :logger
end
