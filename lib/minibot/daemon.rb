require 'socket'

module MiniBot
  class Daemon
    include Events
    include Commands

    attr_reader :config, :commands

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
        close
      end
    end

    private

    def close
      @socket.close if @socket
    end

    def initialize(config)
      @config = DEFAULTS.merge config

      @config[:username] ||= @config[:nick]
      @config[:realname] ||= @config[:nick]
      @commands = []
    end

    def main_loop
      loop do 
        read_commands
        while c = next_command
          dispatch c
        end
      end
    end

    def read_commands
      buffer = @socket.recvfrom(512).first
      commands = buffer.split /\n/

      @commands.last << commands.shift if @commands.last && @commands.last[-1] != ?\r

      @commands += commands
    end

    def next_command
      if @commands.first && @commands.first[-1] == ?\r
        @commands.shift.chomp
      else
        nil
      end
    end

    def connect(server, port)
      @socket = TCPSocket.new(server, port)
    end

    def authenticate(nick, username, realname)
      write "USER #{username} 0 xxx :#{realname}"
      write "NICK #{nick}"
    end

    # Used by the Commands module.
    attr_reader :socket
  end
end

