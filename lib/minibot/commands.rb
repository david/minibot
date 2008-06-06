module MiniBot
  module Commands
    def join(channel)
      write "JOIN #{channel}"
    end

    private

    def write(str)
      @socket.print "#{str}\r\n"
    end

    def pong
      write "PONG #{@host_name}"
    end
  end
end
