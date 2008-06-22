require 'socket'

module MiniBot
  class Daemon
    include Events
    include Commands

    attr_reader :server

    def run
      begin
        connect @servername, @port
        login @username, @realname
        identify @nick, @nickserv_pwd
        main_loop
      ensure
        disconnect
      end
    end

    private

    def initialize(config)
      @servername = config[:server]
      @port = config[:port] || 6667
      @nick = config[:nick]
      @nickserv_pwd = config[:nickserv_pwd]
      @username = config[:username] || @nick
      @realname = config[:realname] || @nick
    end

    def connect(server, port = 6667)
      @server = Server.connect server, port
    end

    def login(username, realname)
      set_user username, realname
    end

    def identify(nick, password = nil)
      set_nick(nick)
      nickserv("identify #{password}") if password
    end

    def disconnect
      @server.disconnect
    end

    def main_loop
      while msg = @server.read
        dispatch msg
      end
    end
  end
end

