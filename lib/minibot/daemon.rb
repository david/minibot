require 'socket'

module MiniBot
  class Daemon
    include Events
    include Commands

    attr_reader :config, :server

    DEFAULTS = {
      :port => 6667,
      :channels => []
    }

    def run
      begin
        connect @config[:server], @config[:port]
        authenticate @config[:nick], @config[:username], @config[:realname]
        join *@config[:channels]
        main_loop
      ensure
        disconnect
      end
    end

    private

    def connect(server, port)
      @server = Server.connect server, port
    end

    def disconnect
      @server.disconnect
    end

    def initialize(config)
      @config = DEFAULTS.merge config

      @config[:username] ||= @config[:nick]
      @config[:realname] ||= @config[:nick]
    end

    def main_loop
      while msg = @server.next_message
        dispatch msg
      end
    end

    def authenticate(nick, username, realname)
      @server.write "USER #{username} 0 xxx :#{realname}"
      @server.write "NICK #{nick}"
    end
  end
end

