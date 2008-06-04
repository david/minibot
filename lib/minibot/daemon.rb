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

    private

    def close
      @socket.close if @socket
    end

    def initialize(options)
      @options = DEFAULTS.merge options
      @event_handlers = Hash.new { |h, k| h[k] = [] }
    end

    def main_loop
      loop { dispatch(@socket.readline) }
    end

    def connect(server, port)
      @socket = TCPSocket.new(server, port)
    end

    def authenticate(nick, username, realname)
      write "NICK #{nick}"
      write "USER #{username} xxx xxx :#{realname}"
    end

    # Used by the Commands module.
    def socket
      @socket
    end
  end
end
