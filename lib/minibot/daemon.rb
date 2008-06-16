require 'socket'

module MiniBot
  class Daemon
    include Events
    include Commands

    DEFAULTS = {
      :join => [],
      :port => 6667
    }

    def run
      begin
        connect(@options[:server], @options[:port])
        authenticate(@options[:nick], @options[:username], @options[:realname])
        main_loop
      ensure
        close
      end
    end

    def error(num, message)
      error = *Events::Constants.constants.select { |c| Events::Constants.const_get(c) == num }

      raise "IRC Error: #{error}: #{message}"
    end

    private

    def close
      @socket.close if @socket
    end

    def initialize(options)
      @options = DEFAULTS.merge options.symbolize_keys

      @options[:username] ||= @options[:nick]
    end

    def main_loop
      loop { dispatch(@socket.readline) }
    end

    def connect(server, port)
      @socket = TCPSocket.new(server, port)
    end

    def authenticate(nick, username, realname)
      write "USER #{username} 0 xxx :#{realname}"
      write "NICK #{nick}"
    end

    # Used by the Commands module.
    def socket
      @socket
    end
  end
end

class Hash
  def symbolize_keys
    inject({}) { |h, (k, v)| h[k.to_sym] = v; h }
  end
end
