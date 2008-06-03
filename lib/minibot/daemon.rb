require 'socket'

module MiniBot
  class Daemon
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

    def event(sym, *args, &block)
      @event_handlers[sym] << block
    end

    def join(channel)
      write "JOIN #{channel}"
    end

    private

    def authenticate(nick, username, realname)
      write "NICK #{nick}"
      write "USER #{username} xxx xxx :#{realname}"
    end

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

    def write(str)
      @socket.print "#{str}\r\n"
    end

    def dispatch(command)
      if match = (/:(\w+)!.+ INVITE \w+ :(#\w+)/.match command)
        handle_event :invite, match[2], match[1]
      elsif match = (/:(\w+)!.+ PRIVMSG (#\w+) :(.+)/.match command)
        handle_event :message, match[2], match[1], match[3]
      else
        handle_event :default, command
      end
    end

    def handle_event(event, *args)
      @event_handlers[event].each { |handler| handler.call *args }
    end
  end
end
