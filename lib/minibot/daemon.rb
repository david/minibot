require 'socket'

module MiniBot
  class Daemon
    DEFAULTS = {
      :join => []
    }

    def close
      @socket.close if @socket
    end

    def run
      begin
        init_socket(@options[:server], 6667)

        write "NICK #{@options[:nick]}"
        write "USER #{@options[:username]} xxx xxx :#{@options[:realname]}"

        join_channels @options[:join]

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

    def join_channels(channels)
      channels.each { |channel| join channel }
    end

    def initialize(options)
      @options = DEFAULTS.merge options
      @event_handlers = Hash.new { |h, k| h[k] = [] }
    end

    def main_loop
      loop do
        dispatch(@socket.readline)
      end
    end

    def init_socket(server, port)
      @socket = TCPSocket.new(server, port)
    end

    def write(str)
      @socket.print "#{str}\r\n"
    end

    def dispatch(command)
      puts command

      if match = (/:(\w+)!.+ INVITE \w+ :(#\w+)/.match command)
        handle_event :invite, match[2], match[1]
      elsif match = (/:(\w+)!.+ PRIVMSG (#\w+) :(.+)/.match command)
        handle_event :message, match[2], match[1], match[3]
      end
    end

    def handle_event(event, *args)
      @event_handlers[event].each { |handler| handler.call self, *args }
    end
  end
end
